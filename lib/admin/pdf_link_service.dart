import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_document/pdf_document.dart';

enum PdfLinkReplacementMode { replaceAll, prefix, suffix }

class PdfLinkToolService {
  PdfLinkToolService();

  String applyLinkReplacement(
    String input, {
    required String find,
    required String replacement,
    required PdfLinkReplacementMode mode,
  }) {
    if (input.isEmpty || find.isEmpty) return input;
    if (!input.toLowerCase().contains(find.toLowerCase())) return input;

    switch (mode) {
      case PdfLinkReplacementMode.replaceAll:
        return input.replaceAll(find, replacement);
      case PdfLinkReplacementMode.prefix:
        return input.replaceFirst(find, replacement);
      case PdfLinkReplacementMode.suffix:
        return input.replaceFirst(find, '$find$replacement');
    }
  }

  String? extractAssetNumber(String? input) {
    if (input == null || input.isEmpty) return null;
    final lower = input.toLowerCase();
    if (!lower.contains('assetnum')) return null;

    final match = RegExp(
      r'assetnum(?:=|%3D|/)([A-Za-z0-9\-_.]+)',
      caseSensitive: false,
    ).firstMatch(input);

    if (match != null) {
      return match.group(1);
    }

    final secondMatch = RegExp(
      r'assetnum(?:=|%3D)([^&?/\\]+)',
      caseSensitive: false,
    ).firstMatch(input);

    return secondMatch?.group(1);
  }

  Future<List<File>> pickPdfFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    return result?.files
            .where((platformFile) => platformFile.path != null)
            .map((platformFile) => File(platformFile.path!))
            .toList() ??
        <File>[];
  }

  Future<List<File>> collectPdfFilesFromFolder(
    String folder, {
    required bool recursive,
  }) async {
    final directory = Directory(folder);
    if (!directory.existsSync()) {
      return <File>[];
    }

    final entities =
        directory.listSync(recursive: recursive, followLinks: false);
    final files = entities.whereType<File>().where((file) {
      final normalized = file.path.toLowerCase();
      return normalized.endsWith('.pdf');
    }).toList();

    files.sort((left, right) => left.path.compareTo(right.path));
    return files;
  }

  Future<List<String>> extractLinksFromPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();

    try {
      final doc = PdfDocument.open(bytes);
      final links = <String>{};
      for (var pageIndex = 0; pageIndex < doc.pageCount; pageIndex++) {
        final page = doc.page(pageIndex);
        for (final annotation in page.annotations) {
          if (annotation is! PdfLinkAnnotation) continue;
          final action = annotation.action;
          if (action is PdfUriAction) {
            links.add(action.uri);
          }
        }
      }
      return links.toList();
    } on Object {
      return _extractLinksFromRawBytes(bytes);
    }
  }

  Future<String> processPdfFile(
    File pdfFile, {
    required String find,
    required String replacement,
    required PdfLinkReplacementMode mode,
    required String outputFolder,
  }) async {
    final bytes = await pdfFile.readAsBytes();
    final outputFile = File(p.join(
      outputFolder,
      '${p.basenameWithoutExtension(pdfFile.path)}_updated.pdf',
    ));

    try {
      final doc = PdfDocument.open(bytes);
      final editor = PdfEditor(doc);
      var changed = false;

      for (var pageIndex = 0; pageIndex < doc.pageCount; pageIndex++) {
        final page = doc.page(pageIndex);
        final linkAnnotations = page.annotations.whereType<PdfLinkAnnotation>();

        for (final annotation in linkAnnotations) {
          final action = annotation.action;
          if (action is! PdfUriAction) continue;

          final updatedUri = applyLinkReplacement(
            action.uri,
            find: find,
            replacement: replacement,
            mode: mode,
          );
          if (updatedUri == action.uri) continue;

          editor.removeAnnotation(pageIndex, annotation);
          editor.addLinkToUri(pageIndex, [annotation.rect], uri: updatedUri);
          changed = true;
        }
      }

      if (!changed) {
        final currentValue = String.fromCharCodes(bytes);
        if (!currentValue.contains(find)) {
          return pdfFile.path;
        }

        final updatedBytes = _replaceInBytes(bytes, find, replacement, mode);
        if (updatedBytes == null || _listsEqual(updatedBytes, bytes)) {
          return pdfFile.path;
        }

        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(updatedBytes);
        return outputFile.path;
      }

      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(editor.save());
      return outputFile.path;
    } on Object {
      final updatedBytes = _replaceInBytes(bytes, find, replacement, mode);
      if (updatedBytes == null || _listsEqual(updatedBytes, bytes)) {
        return pdfFile.path;
      }

      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(updatedBytes);
      return outputFile.path;
    }
  }

  Future<String> exportLinksCsv(
    List<Map<String, String>> rows,
    String outputFolder,
  ) async {
    final outputFile = File(p.join(outputFolder, 'discovered_links.csv'));
    await outputFile.parent.create(recursive: true);

    final csvData = csv.encode([
      ['fileName', 'link'],
      ...rows.map((row) => [row['fileName'] ?? '', row['link'] ?? '']),
    ]);

    await outputFile.writeAsString(csvData);
    return outputFile.path;
  }

  Future<String> exportAssetNumbersCsv(
    List<Map<String, String>> rows,
    String outputFolder,
  ) async {
    final outputFile = File(p.join(outputFolder, 'dna_asset_numbers.csv'));
    await outputFile.parent.create(recursive: true);

    final csvData = csv.encode([
      ['site', 'assetNumber', 'fileName', 'link'],
      ...rows.map((row) => [
            row['site'] ?? '',
            row['assetNumber'] ?? '',
            row['fileName'] ?? '',
            row['link'] ?? '',
          ]),
    ]);

    await outputFile.writeAsString(csvData);
    return outputFile.path;
  }

  List<String> _extractLinksFromRawBytes(List<int> bytes) {
    final content = String.fromCharCodes(bytes);
    final matches = RegExp(r'https?://[^\s"<>]+').allMatches(content);
    return matches.map((match) => match.group(0)!).toSet().toList();
  }

  List<int>? _replaceInBytes(
    List<int> bytes,
    String find,
    String replacement,
    PdfLinkReplacementMode mode,
  ) {
    final targetBytes = utf8.encode(find);
    if (targetBytes.isEmpty) {
      return null;
    }

    final replacementBytes = utf8.encode(replacement);
    final result = <int>[];
    var index = 0;
    var replaced = false;

    while (index < bytes.length) {
      if (_matchesBytes(bytes, index, targetBytes)) {
        result.addAll(replacementBytes);
        index += targetBytes.length;
        replaced = true;
        continue;
      }

      result.add(bytes[index]);
      index += 1;
    }

    if (!replaced) {
      return null;
    }

    return result;
  }

  bool _matchesBytes(List<int> bytes, int startIndex, List<int> targetBytes) {
    if (startIndex + targetBytes.length > bytes.length) {
      return false;
    }

    for (var offset = 0; offset < targetBytes.length; offset++) {
      if (bytes[startIndex + offset] != targetBytes[offset]) {
        return false;
      }
    }

    return true;
  }

  bool _listsEqual(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
