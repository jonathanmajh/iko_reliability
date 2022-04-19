import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class SettingsSiteList extends StatefulWidget {
  const SettingsSiteList({Key? key}) : super(key: key);

  @override
  State<SettingsSiteList> createState() => _SettingsSiteListState();
}

class _SettingsSiteListState extends State<SettingsSiteList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _createDataTable(),
    );
  }

  DataTable _createDataTable() {
    return DataTable(columns: _createColumns(), rows: _createRows());
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text('Site ID')),
      const DataColumn(label: Text('Site Name')),
      const DataColumn(label: Text('Site Org-ID'))
    ];
  }

  List<DataRow> _createRows() {
    return _books
        .map((book) => DataRow(cells: [
              DataCell(TextFormField(
                initialValue: "Test",
              )),
              DataCell(TextFormField(initialValue: "Test")),
              DataCell(TextFormField(initialValue: "Test"))
            ]))
        .toList();
  }
}
