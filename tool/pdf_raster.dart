// Rasterizes PDF pages to 24bpp BMP via the app's bundled pdfium.dll, for
// visual inspection of print pack layouts:
//   dart run tool/pdf_raster.dart <in.pdf> --pages 1,2,3 --scale 1.2 --out build/tmp/p
// Convert to PNG for viewing with:
//   Add-Type -AssemblyName System.Drawing
//   Get-ChildItem build\tmp\*.bmp | ForEach-Object {
//     $img = [System.Drawing.Image]::FromFile($_.FullName)
//     $img.Save(($_.FullName -replace '.bmp$', '.png'),
//         [System.Drawing.Imaging.ImageFormat]::Png); $img.Dispose() }
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final DynamicLibrary pdfium = DynamicLibrary.open(
  r'build\windows\x64\runner\Debug\pdfium.dll',
);

final void Function() _init = pdfium
    .lookupFunction<Void Function(), void Function()>("FPDF_InitLibrary");
final Pointer<Void> Function(Pointer<Char>, Pointer<Char>) _loadDoc = pdfium
    .lookupFunction<
      Pointer<Void> Function(Pointer<Char>, Pointer<Char>),
      Pointer<Void> Function(Pointer<Char>, Pointer<Char>)
    >("FPDF_LoadDocument");
final Pointer<Char> _pwdNull = Pointer<Char>.fromAddress(0);
final int Function(Pointer<Void>) _pageCount = pdfium
    .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
      "FPDF_GetPageCount",
    );
final Pointer<Void> Function(Pointer<Void>, int) _loadPage = pdfium
    .lookupFunction<
      Pointer<Void> Function(Pointer<Void>, Int32),
      Pointer<Void> Function(Pointer<Void>, int)
    >("FPDF_LoadPage");
final Pointer<Void> Function(int, int, int, Pointer<Void>, int)
_bitmapCreateEx = pdfium
    .lookupFunction<
      Pointer<Void> Function(Uint32, Uint32, Int32, Pointer<Void>, Int32),
      Pointer<Void> Function(int, int, int, Pointer<Void>, int)
    >("FPDFBitmap_CreateEx");
final int Function(Pointer<Void>, int, int, int, int, int) _bitmapFillRect =
    pdfium.lookupFunction<
      Int32 Function(Pointer<Void>, Int32, Int32, Uint32, Uint32, Uint32),
      int Function(Pointer<Void>, int, int, int, int, int)
    >("FPDFBitmap_FillRect");
final Pointer<Uint8> Function(Pointer<Void>) _bitmapBuffer = pdfium
    .lookupFunction<
      Pointer<Uint8> Function(Pointer<Void>),
      Pointer<Uint8> Function(Pointer<Void>)
    >("FPDFBitmap_GetBuffer");
final void Function(Pointer<Void>, Pointer<Void>, int, int, int, int, int, int)
_render = pdfium
    .lookupFunction<
      Void Function(
        Pointer<Void>,
        Pointer<Void>,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
      ),
      void Function(Pointer<Void>, Pointer<Void>, int, int, int, int, int, int)
    >("FPDF_RenderPageBitmap");
final void Function(Pointer<Void>) _closePage = pdfium
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      "FPDF_ClosePage",
    );
final void Function(Pointer<Void>) _closeDoc = pdfium
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      "FPDF_CloseDocument",
    );
final void Function(Pointer<Void>) _bitmapDestroy = pdfium
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      "FPDFBitmap_Destroy",
    );

final Pointer<Char> _null = Pointer.fromAddress(0);

Future<void> main(List<String> args) async {
  final pdf = args.first;
  final pagesArg =
      RegExp(r'--pages ([\d,]+)').firstMatch(args.join(' '))?.group(1) ?? '1';
  final scale =
      double.tryParse(
        RegExp(r'--scale ([\d.]+)').firstMatch(args.join(' '))?.group(1) ?? '',
      ) ??
      1.5;
  final outPrefix =
      RegExp(r'--out (\S+)').firstMatch(args.join(' '))?.group(1) ??
      'build/tmp/page';

  _init();
  final pathC = malloc<Char>(pdf.length + 1);
  final pathList = pathC.cast<Uint8>().asTypedList(pdf.length + 1);
  for (var i = 0; i < pdf.length; i++) {
    pathList[i] = pdf.codeUnitAt(i);
  }
  pathList[pdf.length] = 0;
  final doc = _loadDoc(pathC, _pwdNull);
  if (doc == _null) {
    stderr.writeln('load failed');
    return;
  }
  stdout.writeln('${pdf}: ${_pageCount(doc)} pages');

  Directory('build/tmp').createSync(recursive: true);
  for (final p in pagesArg.split(',').map(int.parse)) {
    final page = _loadPage(doc, p - 1);
    if (page == _null) {
      stdout.writeln('page $p: load failed');
      continue;
    }
    final (w, h) = _pageSize(pdf, scale);
    // FPDFBitmap_BGRA = 4; 4th arg = no external buffer
    final bmp = _bitmapCreateEx(w, h, 4, Pointer<Void>.fromAddress(0), 0);
    _bitmapFillRect(bmp, 0, 0, w, h, 0xFFFFFFFF);
    _render(bmp, page, 0, 0, w, h, 0, 0);
    final pixels = _bitmapBuffer(bmp).asTypedList(w * h * 4);
    _writeBmp('$outPrefix-$p.bmp', w, h, pixels);
    stdout.writeln('page $p: ${w}x$h -> $outPrefix-$p.bmp');
    _bitmapDestroy(bmp);
    _closePage(page);
  }
  _closeDoc(doc);
  malloc.free(pathC);
}

// pdfium's FPDF_GetPageWidth returns unusable values in this build, so page
// size comes from the /MediaBox in the file (all pages share it).
(int, int) _pageSize(String pdf, double scale) {
  final raw = latin1.decode(File(pdf).readAsBytesSync(), allowInvalid: true);
  final m = RegExp(r'/MediaBox \[ [\d. ]+ \]').firstMatch(raw);
  final nums = m == null
      ? null
      : RegExp(r'[\d.]+')
            .allMatches(m.group(0)!)
            .map((e) => double.parse(e.group(0)!))
            .toList();
  final wPt = nums != null ? nums[2] - nums[0] : 612.0;
  final hPt = nums != null ? nums[3] - nums[1] : 792.0;
  return ((wPt * scale).toInt(), (hPt * scale).toInt());
}

void _writeBmp(String path, int w, int h, List<int> bgra) {
  final rowBytes = w * 3;
  final pad = (4 - (rowBytes % 4)) % 4;
  final dataSize = (rowBytes + pad) * h;
  final f = File(path).openSync(mode: FileMode.write);
  final head = <int>[
    0x42, 0x4D, // 'BM'
    54 + dataSize, 0, 0, 0,
    0, 0, 0, 0,
    54, 0, 0, 0,
    40, 0, 0, 0,
    w & 0xFF, (w >> 8) & 0xFF, (w >> 16) & 0xFF, 0,
    h & 0xFF, (h >> 8) & 0xFF, (h >> 16) & 0xFF, 0,
    1, 0, 24, 0,
    0, 0, 0, 0,
    dataSize, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ];
  f.writeFromSync(head);
  final row = <int>[];
  for (var y = h - 1; y >= 0; y--) {
    row.clear();
    final off = y * w * 4;
    for (var x = 0; x < w; x++) {
      final i = off + x * 4;
      row
        ..add(bgra[i])
        ..add(bgra[i + 1])
        ..add(bgra[i + 2]); // B,G,R
    }
    f.writeFromSync(row);
    if (pad > 0) f.writeFromSync(List.filled(pad, 0));
  }
  f.closeSync();
}
