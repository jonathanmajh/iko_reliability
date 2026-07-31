import 'dart:io';

import 'package:pdf_document/pdf_document.dart';
import 'package:path/path.dart' as p;

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
        final prefixValue =
            replacement.endsWith(find) ? replacement : '$replacement$find';
        return input.replaceFirst(find, prefixValue);
      case PdfLinkReplacementMode.suffix:
        final suffixValue =
            replacement.startsWith(find) ? replacement : '$find$replacement';
        return input.replaceFirst(find, suffixValue);
    }
  }

  /// Reads every external (URI) link annotation from a PDF.
  Future<List<String>> extractLinksFromPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final doc = PdfDocument.open(bytes);

    final links = <String>{};
    for (var i = 0; i < doc.pageCount; i++) {
      for (final annotation in doc.pages[i].annotations) {
        if (annotation is PdfLinkAnnotation) {
          final action = annotation.action;
          if (action is PdfUriAction) links.add(action.uri);
        }
      }
    }
    return links.toList();
  }

  /// Rewrites matching link URIs in place and saves an updated copy.
  Future<String> processPdfFile(
    File pdfFile, {
    required String find,
    required String replacement,
    required PdfLinkReplacementMode mode,
    required String outputFolder,
  }) async {
    final bytes = await pdfFile.readAsBytes();
    final doc = PdfDocument.open(bytes);
    final editor = PdfEditor(doc);

    for (var pageIndex = 0; pageIndex < doc.pageCount; pageIndex++) {
      final page = doc.pages[pageIndex];
      // Snapshot first: we'll mutate the page's annotation list as we go.
      final linkAnnotations =
          page.annotations.whereType<PdfLinkAnnotation>().toList();

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

        // No in-place URI setter exists yet, so swap the annotation:
        // same rect, new target.
        editor.removeAnnotation(pageIndex, annotation);
        editor.addLinkToUri(
          pageIndex,
          [annotation.rect],
          uri: updatedUri,
        );
      }
    }

    final outputFile = File(p.join(outputFolder,
        '${p.basenameWithoutExtension(pdfFile.path)}_updated.pdf'));
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsBytes(editor.save());

    return outputFile.path;
  }
}
