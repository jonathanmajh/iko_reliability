// Shared Roboto loader for the WO print pack CLI tools (dart:io based).
//
// The renderer falls back to built-in Helvetica (cp1252 only) when the
// bundled Roboto TTFs are not found, so tools still run from any directory
// — just with reduced character coverage.

import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:iko_reliability_flutter/print/wo_packet.dart';

/// Loads the bundled Roboto TTFs from [dir] (default: the repo fonts dir).
/// Returns null when the files are missing.
WoPrintFonts? loadWoPrintFontsFromDirectory([String dir = 'fonts']) {
  pw.Font load(String name) {
    final bytes = File('$dir/Roboto-$name.ttf').readAsBytesSync();
    return pw.Font.ttf(
      ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes),
    );
  }

  try {
    return WoPrintFonts(
      base: load('Regular'),
      bold: load('Bold'),
      italic: load('Italic'),
      boldItalic: load('BoldItalic'),
    );
  } on FileSystemException {
    return null;
  }
}
