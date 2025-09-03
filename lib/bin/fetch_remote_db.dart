import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

Future<Uint8List> fetchAndUnzipDb(String url, String dbFileName) async {
  // Fetch the ZIP file
  // TODO ahah turns out this doesn't work
  final response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;

  // Decode the ZIP archive
  final archive = ZipDecoder().decodeBytes(bytes);

  // Find the SQLite file in the archive
  for (final file in archive) {
    if (file.name == dbFileName) {
      return file.content as Uint8List;
    }
  }
  throw Exception('Database file not found in ZIP');
}
