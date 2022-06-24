import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

part 'observation_list_storage.g.dart';

@HiveType(typeId: 3)
class Observations {
  @HiveField(0)
  String code;
  @HiveField(1)
  String description;
  @HiveField(2)
  String? action;

  Observations({
    required this.code,
    required this.description,
    this.action,
  });
}

@HiveType(typeId: 2)
class ObservationList {
  @HiveField(0)
  String meterGroup;

  @HiveField(1)
  String inspect;

  @HiveField(2)
  String extendedDescription;

  @HiveField(3)
  int frequency;

  @HiveField(4)
  String freqUnit;

  @HiveField(5)
  String condition;

  @HiveField(6)
  List<Observations> observations;

  @HiveField(7)
  String craft;

  ObservationList(
      {required this.condition,
      required this.extendedDescription,
      required this.freqUnit,
      required this.frequency,
      required this.inspect,
      required this.meterGroup,
      required this.craft,
      required this.observations});
}

void loadObservationList() async {
  print('Picking Files');
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: false, withData: true);
  List<PlatformFile> files = [];
  if (result != null) {
    files = result.files.map((files) => (files)).toList();
    var decoder = SpreadsheetDecoder.decodeBytes(files.first.bytes!);
    var sheet = decoder.tables.values.first;
    final box = Hive.box('observationList');
    await box.clear();
    var observation;
    List<Observations> observations = [];
    for (var i = 1; i < sheet.maxRows; i++) {
      var row = sheet.rows[i];
      try {
        if (row[0] != null) {
          observation = ObservationList(
            condition: row[12],
            extendedDescription: row[4],
            freqUnit: row[10].substring(row[10].length - 1, 1),
            frequency: int.parse(row[10].substring(0, row[10].length - 1)),
            inspect: row[2],
            meterGroup: row[0],
            craft: row[11].substring(0, 1),
            observations: [],
          );
        }
        if (row[5] != null) {
          observations.add(
              Observations(code: row[5], description: row[6], action: row[7]));
        }
        if (row[5] == null) {
          observation.observations = observations;
          box.put(observation.meterGroup, observation);
          observations = [];
        }
      } catch (err) {
        print('Row ${i + 1} is problematic\n$err');
      }
    }
  }
  print('Finished Loading');
}

ObservationList getObservation(String meterCode) {
  final box = Hive.box('observationList');
  return box.get(meterCode);
}
