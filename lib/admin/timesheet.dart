import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class WorkingDay {
  final String checkin;
  final String checkout;
  final String siteid;
  final String laborcode;
  final double hours;
  final String weekday;

  const WorkingDay({
    required this.checkin,
    required this.checkout,
    required this.siteid,
    required this.laborcode,
    required this.hours,
    required this.weekday,
  });
}

class LaborRecord {
  final String siteid;
  final String laborid;
  final String laborCode;
  final String name;

  const LaborRecord({
    required this.siteid,
    required this.laborid,
    required this.laborCode,
    required this.name,
  });
}

class TimesheetEntry {
  final int year;
  final int month;
  final String siteid;
  final String laborcode;
  final double hours;

  const TimesheetEntry({
    required this.year,
    required this.month,
    required this.siteid,
    required this.laborcode,
    required this.hours,
  });
}

class TimesheetView extends StatefulWidget {
  const TimesheetView({super.key});

  @override
  State<TimesheetView> createState() => _TimesheetViewState();
}

class _TimesheetViewState extends State<TimesheetView>
    with SingleTickerProviderStateMixin {
  String selectedSite = 'ANT';
  int selectedMonth = DateTime.now().month - 1;
  int selectedYear = DateTime.now().year;
  Map<UniqueKey, TimesheetEntry> timesheets = {};
  List<WorkingDay> workingDays = [];
  List<LaborRecord> labors = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(vsync: this, length: 3); //hard-coded tab length of 3
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Timesheet Generator"),
          // keep back button with a right side hamburger menu
          leading: (ModalRoute.of(context)?.canPop ?? false)
              ? const BackButton()
              : null,
        ),
        body: Scaffold(
          appBar: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  icon: Icon(
                Icons.tune,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
              Tab(
                  icon: Icon(
                Icons.cloud_upload,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
              Tab(
                  icon: Icon(
                Icons.edit_note,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              monthYear(),
              timesheetTable(),
              workingDays.isNotEmpty ? uploadDetails() : const Text('no data'),
            ],
          ),
        ));
  }

  Widget monthYear() {
    return Column(
      children: [
        const Text('Select a Year and Month to generate timesheets for'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton(
              items: [DateTime.now().year, DateTime.now().year - 1]
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                    value: value, child: Text(value.toString()));
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  selectedYear = value!;
                });
              },
              value: selectedYear,
            ),
            DropdownButton(
              items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                    value: value, child: Text(value.toString()));
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  selectedMonth = value!;
                });
              },
              value: selectedMonth == 0 ? 12 : selectedMonth,
            ),
            DropdownButton(
              items: ['ANT', 'COM', 'GR', 'GP', 'CAM']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSite = value.toString();
                });
              },
              value: selectedSite,
            ),
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: []),
        ElevatedButton(
          onPressed: () {
            addTimesheet(context);
          },
          child: const Text('Add Timesheet Entry'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              workingDays.clear();
              for (var timesheet in timesheets.values) {
                workingDays.addAll(generateWorkDays(timesheet));
              }
            });
          },
          child: const Text(
            "Generate Uploads",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            copyExportDetails(workingDays);
          },
          child: const Text('Copy to Clipboard'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              labors = laborFromClipboard();
            });
          },
          child: const Text('Read from Clipboard'),
        ),
      ],
    );
  }

  void addTimesheet(BuildContext context) {
    TextEditingController laborCodeController = TextEditingController();
    String laborCode = '';
    TextEditingController hourController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: laborCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Labor Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                DropdownButton(
                  items:
                      labors.map<DropdownMenuItem<String>>((LaborRecord value) {
                    return DropdownMenuItem<String>(
                        value: value.laborCode, child: Text(value.name));
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      laborCode = value!;
                    });
                  },
                  value: laborCode,
                ),
                TextField(
                  controller: hourController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      timesheets[UniqueKey()] = TimesheetEntry(
                        year: selectedYear,
                        month: selectedMonth,
                        siteid: selectedSite,
                        laborcode: laborCode,
                        hours: double.tryParse(hourController.text) ?? 0,
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "OK",
                  ),
                ),
              ],
            ),
          ));
        });
  }

  Widget uploadDetails() {
    return ListView(
      children: <Widget>[
        ListView.builder(
            shrinkWrap: true,
            prototypeItem: ListTile(title: Text(workingDays.first.laborcode)),
            itemCount: workingDays.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(workingDays[index].checkout),
              );
            })
      ],
    );
  }

  Widget timesheetTable() {
    if (timesheets.isEmpty) {
      return const Text('Add some timesheets');
    }
    return DataTable(
        rows: timesheets.entries.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.value.siteid)),
            DataCell(Text(item.value.laborcode)),
            DataCell(Text(item.value.hours.toString())),
          ]);
        }).toList(),
        columns: const [
          DataColumn(
            label: Expanded(
              child: Text('SiteID'),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text('LaborCode'),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text('Hours'),
            ),
          )
        ]);
  }
}

int workingDaysOfMonth(int year, int month) {
  int totalDays = DateUtils.getDaysInMonth(year, month);
  int workDays = 0;
  for (int i = 1; i <= totalDays; i++) {
    if (DateTime(year, month, i).weekday < 6) {
      workDays++;
    }
  }
  return workDays;
}

List<WorkingDay> generateWorkDays(TimesheetEntry worker) {
  List<WorkingDay> entries = [];
  int workday = 8;
  double hoursLeft = worker.hours;
  int currentDay = 0;
  DateTime checkin = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat wdFormatter = DateFormat('EEEE');
  if (worker.hours / workingDaysOfMonth(worker.year, worker.month) > 8) {
    // determining length of workday
    workday = 12;
  }
  // create a bunch of standard length work days
  while (hoursLeft > 0.01) {
    currentDay++;
    checkin = DateTime(worker.year, worker.month, currentDay, 8);
    if (checkin.weekday > 5) {
      continue;
    }
    if (hoursLeft < workday) {
      final minutes = ((hoursLeft - hoursLeft.floor()) * 60).floor();
      entries.add(WorkingDay(
        checkin: formatter.format(checkin),
        checkout: formatter.format(
            checkin.add(Duration(hours: hoursLeft.floor(), minutes: minutes))),
        siteid: worker.siteid,
        laborcode: worker.laborcode,
        hours: hoursLeft,
        weekday: wdFormatter.format(checkin),
      ));
    } else {
      entries.add(WorkingDay(
        checkin: formatter.format(checkin),
        checkout: formatter.format(checkin.add(Duration(hours: workday))),
        siteid: worker.siteid,
        laborcode: worker.laborcode,
        hours: workday * 1.0,
        weekday: wdFormatter.format(checkin),
      ));
    }
    hoursLeft = hoursLeft - workday;
  }
  return entries;
}

void copyExportDetails(List<WorkingDay> workingDays) {
  String allData = '''<html><head><style>
<!--table .xl65	{mso-number-format:"yyyy\\-mm\\-dd\\ hh\:mm";} -->
</style></head>
<body><table><!--StartFragment--><tr><td>Employee#</td><td>LABORCODE</td><td>DAY</td><td>TIMEIN</td><td>TIMEOUT</td><td>HOURS</td></tr>''';
  for (final days in workingDays) {
    allData =
        '$allData<tr><td></td><td>${days.laborcode}</td><td>${days.weekday}</td><td class=xl65>${days.checkin}</td><td class=xl65>${days.checkout}</td><td>${days.hours}</td></tr>';
  }
  allData = "$allData</table><!--EndFragment--></body></html>";
  Clipboard.setData(ClipboardData(text: allData)).then((_) {
    return;
  });
}

List<LaborRecord> laborFromClipboard() {
  List<LaborRecord> labors = [];
  LineSplitter ls = const LineSplitter();
  Clipboard.getData(Clipboard.kTextPlain).then((value) {
    for (final line in ls.convert(value!.text!)) {
      final words = line.split('\t');
      labors.add(
        LaborRecord(
          siteid: words[3],
          laborid: words[0],
          laborCode: words[2],
          name: words[1],
        ),
      );
    }
  });
  return labors;
}
