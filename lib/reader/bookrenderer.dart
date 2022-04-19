import 'dart:io';

import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' show parse;

class EpubPage extends StatefulWidget {
  const EpubPage({Key? key}) : super(key: key);
  @override
  State<EpubPage> createState() => _EpubPageState();
}

class _EpubPageState extends State<EpubPage> {
  @override
  void initState() {
    super.initState();
    String fileName = '/home/jonathan/Downloads/86v9.epub';
    _parseBook(fileName);
  }

  var _book = EpubBook();
  var _chapters = <EpubChapter>[];
  final _html = parse(
      "<body><p>test</p><p>You can pass a String or list of bytes to <code>parse</code>.</p></body>");

  Future<void> _parseBook(String filename) async {
    var bytes = File(filename).readAsBytesSync();
    EpubBook epubBook = await EpubReader.readBook(bytes);
    setState(() {
      _book = epubBook;
      _chapters = _book.Chapters!.cast<EpubChapter>();
    });
  }

  Widget _buildChapter(int i) {
    return ListTile(
      title: Text(_chapters[i].Title ?? 'loading'),
      subtitle: Text(_chapters[i].HtmlContent ?? 'loading'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("app title"),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _chapters.length,
          itemBuilder: (BuildContext context, int position) {
            return _buildChapter(position);
          }),
    );
  }
}
