// Smoke test: batch render of two synthetic packets (no Maximo calls).
// Expect 3 pages for the batch (cover + child + second cover) and 1 for a
// single packet. Run: dart run tool/wo_print_batch_smoke.dart
import 'dart:io';

import 'package:iko_reliability_flutter/print/wo_packet.dart';

import 'wo_print_fonts.dart';

Future<void> main() async {
  final p1 = WoPacket(
    header: {
      'wonum': 'WOA',
      'description': 'batch smoke a',
      'status': 'RELEASED',
      'siteid': 'AA',
    },
    tasks: [
      const WoTask(wonum: 'WOA', taskid: '10', description: 'task a1'),
    ],
    children: [
      const WoChildPacket(
        header: {
          'wonum': 'WOA-1',
          'description': 'child one',
          'status': 'RELEASED',
          'parent': 'WOA',
        },
        tasks: [
          WoTask(wonum: 'WOA-1', taskid: '10', description: 't'),
        ],
      ),
    ],
  );
  final p2 = WoPacket(
    header: {
      'wonum': 'WOB',
      'description': 'batch smoke b',
      'status': 'RELEASED',
      'siteid': 'AA',
    },
    tasks: const [],
  );
  final bytes = await buildWoBatchPdf([p1, p2], fonts: loadWoPrintFontsFromDirectory());
  final s = String.fromCharCodes(bytes);
  final pages = RegExp(r'/Type\s*/Page[^s]').allMatches(s).length;
  stdout.writeln('batch pages: $pages (expect 3)');
  final single = await buildWoPacketPdf(p2, fonts: loadWoPrintFontsFromDirectory());
  final sp = RegExp(r'/Type\s*/Page[^s]')
      .allMatches(String.fromCharCodes(single))
      .length;
  stdout.writeln('single pages: $sp (expect 1)');

  // sanitizer: combining marks / boxes / zero-width chars are stripped
  const cases = {
    'hau\u0308l off topsol\u0308': 'haul off topsol',
    'Equipment/Process I\u200E\u030Amprovement - Mechanica\u0308l':
        'Equipment/Process Improvement - Mechanical',
    '250\u25A0 x 225\u25A0': '250 x 225',
    'Joya\u0308e\u200B instructions': 'Joyae instructions',
    'cafe\u0301 \u2013 done \u2014 ok': 'cafe - done - ok',
    // precomposed European characters are kept for the embedded Roboto font
    'Zkou\u0161ka lo\u010F - na\u0142\u0105dowy':
        'Zkou\u0161ka lo\u010F - na\u0142\u0105dowy',
  };
  for (final e in cases.entries) {
    final out = sanitizePdfText(e.key);
    stdout.writeln(
        '${out == e.value ? 'OK  ' : 'FAIL'} "$out" (expect "${e.value}")');
  }
}
