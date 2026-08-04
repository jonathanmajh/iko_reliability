import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iko_reliability_flutter/admin/pdf_link_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('PdfLinkToolService', () {
    late PdfLinkToolService service;

    setUp(() {
      service = PdfLinkToolService();
    });

    test('replaces matching links using find-and-replace mode', () {
      const input = 'https://old.example.com/path/page';

      final result = service.applyLinkReplacement(
        input,
        find: 'old.example.com',
        replacement: 'new.example.com',
        mode: PdfLinkReplacementMode.replaceAll,
      );

      expect(result, 'https://new.example.com/path/page');
    });

    test('prefixes URLs when prefix mode is selected', () {
      const input = 'https://example.com/path';

      final result = service.applyLinkReplacement(
        input,
        find: 'example.com',
        replacement: 'base.example.com',
        mode: PdfLinkReplacementMode.prefix,
      );

      expect(result, 'https://base.example.com/path');
    });

    test('extracts asset numbers from assetnum urls', () {
      const input = 'https://sharepoint/sites/demo/assetnum=ABC12345';

      final result = service.extractAssetNumber(input);

      expect(result, 'ABC12345');
    });

    test('preserves binary bytes while replacing links in a PDF-like payload',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('pdf_link_service_test_binary');
      addTearDown(() async => tempDir.delete(recursive: true));

      final sourceFile = File(p.join(tempDir.path, 'sample.pdf'));
      final sourceBytes = <int>[
        ...utf8.encode('%PDF-1.4\n'),
        0x00,
        0xFF,
        0x01,
        ...utf8.encode('/URI (https://old.example.com/path)\n'),
      ];
      await sourceFile.writeAsBytes(sourceBytes, flush: true);

      final outputDir = Directory(p.join(tempDir.path, 'output'));
      await outputDir.create(recursive: true);

      final result = await service.processPdfFile(
        sourceFile,
        find: 'old.example.com',
        replacement: 'new.example.com',
        mode: PdfLinkReplacementMode.replaceAll,
        outputFolder: outputDir.path,
      );

      expect(result, p.join(outputDir.path, 'sample_updated.pdf'));
      final outputBytes = await File(result).readAsBytes();
      expect(
          outputBytes, contains(utf8.encode('https://new.example.com/path')));
      expect(outputBytes, contains([0x00, 0xFF, 0x01]));
    });

    test('leaves the source file untouched when no matching links are found',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('pdf_link_service_test');
      addTearDown(() async => tempDir.delete(recursive: true));

      final sourceFile = File(p.join(tempDir.path, 'sample.pdf'));
      await sourceFile.writeAsString('plain pdf content', flush: true);

      final outputDir = Directory(p.join(tempDir.path, 'output'));
      await outputDir.create(recursive: true);

      final result = await service.processPdfFile(
        sourceFile,
        find: 'missing-value',
        replacement: 'replacement-value',
        mode: PdfLinkReplacementMode.replaceAll,
        outputFolder: outputDir.path,
      );

      expect(result, sourceFile.path);
      expect(await sourceFile.readAsString(), 'plain pdf content');
      expect(File(p.join(outputDir.path, 'sample.pdf')).existsSync(), isFalse);
    });
  });
}
