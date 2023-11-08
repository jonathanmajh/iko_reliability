import 'dart:convert';

import 'package:auto_route/auto_route.dart';
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
  final double hours;

  const LaborRecord(
      {required this.siteid,
      required this.laborid,
      required this.laborCode,
      required this.name,
      required this.hours});
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

@RoutePage()
class TimesheetPage extends StatefulWidget {
  const TimesheetPage({super.key});

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage>
    with SingleTickerProviderStateMixin {
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
          ],
        ),
        const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, children: []),
        ElevatedButton(
          onPressed: () async {
            labors = await laborFromClipboard();
            setState(() {
              for (LaborRecord labor in labors) {
                timesheets[UniqueKey()] = TimesheetEntry(
                  year: selectedYear,
                  month: selectedMonth,
                  siteid: labor.siteid,
                  laborcode: labor.laborCode,
                  hours: labor.hours,
                );
              }
            });
            // addTimesheet(context);
          },
          child: const Text('Add Timesheet Entry From Clipboard'),
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
            // Clipboard.setData(ClipboardData(text: allData)).then((_) {return;});
            // TODO IKO ID	SiteID	Labor Code	Name	Hours Worked
          },
          child: const Text('Copy Header for Timesheet Format'),
        ),
      ],
    );
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
<!--table .xl65	{mso-number-format:"yyyy\\-mm\\-dd\\ hh:mm";} -->
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

Future<List<LaborRecord>> laborFromClipboard() async {
  List<LaborRecord> labors = [];
  LineSplitter ls = const LineSplitter();
  ClipboardData? value = await Clipboard.getData(Clipboard.kTextPlain);
  for (final line in ls.convert(value!.text!)) {
    final words = line.split('\t');
    labors.add(
      LaborRecord(
        siteid: words[1],
        laborid: words[0],
        laborCode: words[2],
        name: words[3],
        hours: double.tryParse(words[4])!,
      ),
    );
  }
  return labors;
}
