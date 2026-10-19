import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

Future<Uint8List> fetchAndUnzipDb(String url, String dbFileName) async {
  // Fetch the ZIP file
  final response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;

  // Decode the ZIP archive
  final archive = ZipDecoder().decodeBytes(bytes);

  // Find the SQLite file in the archive
  for (final file in archive) {
    if (file.name == dbFileName) {
      return file.content;
    }
  }
  throw Exception('Database file not found in ZIP');
}

Future<String> fetchRemoteVersion() async {
  final response = await http
      .get(Uri.parse('https://iko-proxy.jonathanmajh.workers.dev/.version'));
  if (response.statusCode == 200) {
    return response.body.trim();
  } else {
    throw Exception('Failed to fetch remote version');
  }
}
