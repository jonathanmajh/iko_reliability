https://blog.logrocket.com/flutter-datatable-widget-guide-displaying-data/

import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  List<Map> _books = [
    {
      'id': 100,
      'title': 'Flutter Basics',
      'author': 'David John'
    },
    {
      'id': 102,
      'title': 'Git and GitHub',
      'author': 'Merlin Nick'
    },
    {
      'id': 101,
      'title': 'Flutter Basics',
      'author': 'David John'
    },
  ];
  bool? _isEditMode = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('DataTable Demo'),
        ),
        body: ListView(
          children: [
            _createDataTable(),
            _createCheckboxField()
          ],
        ),
      ),
    );
  }
DataTable _createDataTable() {
    return DataTable(columns: _createColumns(), rows: _createRows());
  }
List<DataColumn> _createColumns() {
    return [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Book')),
      DataColumn(label: Text('Author'))
    ];
  }
List<DataRow> _createRows() {
    return _books
        .map((book) => DataRow(cells: [
              DataCell(Text('#' + book['id'].toString())),
              _createTitleCell(book['title']),
              DataCell(Text(book['author']))
            ]))
        .toList();
  }
DataCell _createTitleCell(bookTitle) {
    return DataCell(_isEditMode == true ? 
            TextFormField(initialValue: bookTitle, 
            style: TextStyle(fontSize: 14)) 
            : Text(bookTitle));
  }
Row _createCheckboxField() {
    return Row(
      children: [
        Checkbox(
          value: _isEditMode,
          onChanged: (value) {
            setState(() {
              _isEditMode = value;
            });
          },
        ),
        Text('Edit mode'),
      ],
    );
  }
}