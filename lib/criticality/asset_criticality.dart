import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AssetCriticalityPage extends StatefulWidget {
  const AssetCriticalityPage({Key? key}) : super(key: key);

  @override
  State<AssetCriticalityPage> createState() => _AssetCriticalityPageState();
}

class _AssetCriticalityPageState extends State<AssetCriticalityPage> {
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Criticality'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(columns: columns, rows: rows),
      ),
    );
  }
}
