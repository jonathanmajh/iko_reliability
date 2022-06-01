import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class Asset {
  String assetNumber;
  String name;
  String? parent;
  String siteid;
  String? hierarchy;

  Asset({
    required this.assetNumber,
    this.hierarchy,
    required this.name,
    required this.parent,
    required this.siteid,
  });
}

void loadHierarchy() async {
  print('Picking Files');
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: false, withData: true);
  List<PlatformFile> files = [];
  String msg = '';
  if (result != null) {
    files = result.files.map((files) => (files)).toList();
    msg = 'Selected ${files.length} files';
    var decoder = SpreadsheetDecoder.decodeBytes(files.first.bytes!);
    var sheet = decoder.tables[0];
    Map<String, Map<String, dynamic>> assets = {};
    for (var i = 1; i < sheet!.maxRows; i++) {
      var row = sheet.rows[i];
      if (!assets.containsKey(row[3])) {
        assets[row[3]] = {};
      }
      assets[row[3]]![row[0]] = {}; // TODO fill this out
    }
  } else {
    msg = 'File selector cancelled';
  }
}
