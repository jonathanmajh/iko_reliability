// Smoke test: batch render of two synthetic packets (no Maximo calls).
// Expect 3 pages for the batch (cover + child + second cover) and 1 for a
// single packet. Run: dart run tool/wo_print_batch_smoke.dart
import 'package:iko_reliability_flutter/print/wo_packet.dart';

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
  final bytes = await buildWoBatchPdf([p1, p2]);
  final s = String.fromCharCodes(bytes);
  final pages = RegExp(r'/Type\s*/Page[^s]').allMatches(s).length;
  print('batch pages: $pages (expect 3)');
  final single = await buildWoPacketPdf(p2);
  final sp = RegExp(r'/Type\s*/Page[^s]')
      .allMatches(String.fromCharCodes(single))
      .length;
  print('single pages: $sp (expect 1)');
}
