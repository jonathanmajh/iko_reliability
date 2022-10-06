import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/observation_list_storage.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'end_drawer.dart';
import 'pm_meter_update_functions.dart';

class PmMeterUpdatePage extends StatefulWidget {
  const PmMeterUpdatePage({Key? key}) : super(key: key);

  @override
  State<PmMeterUpdatePage> createState() => _PmMeterUpdatePageState();
}

class _PmMeterUpdatePageState extends State<PmMeterUpdatePage> {
  TextEditingController meterNameController = TextEditingController();
  TextEditingController oldMeterNameController = TextEditingController();
  List<JobPlanMeterCheckMaximo> affectedJobPlans = [];
  ObservationList? meterDetails;
  ObservationList? oldMeterDetails;
  // observation list objs (new, old)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PM Verify and Upload"),
        // keep back button with a right side hamburger menu
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? const BackButton()
            : null,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 550,
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ))),
                      onPressed: () async {
                        try {
                          meterNameController.text =
                              meterNameController.text.toUpperCase();
                          final temp = getObservation(meterNameController.text);
                          setState(() {
                            meterDetails = temp;
                          });
                        } catch (e) {
                          // widget already takes care of null case
                        }
                        try {
                          oldMeterNameController.text =
                              oldMeterNameController.text.toUpperCase();
                          final temp =
                              getObservation(oldMeterNameController.text);
                          setState(() {
                            oldMeterDetails = temp;
                          });
                        } catch (e) {
                          // widget already takes care of null case
                        }
                        if (oldMeterNameController.text.isNotEmpty) {
                          final temp = await getJobtasks(
                              oldMeterNameController.text,
                              Provider.of<MaximoServerNotifier>(context,
                                      listen: false)
                                  .maximoServerSelected);
                          setState(() {
                            affectedJobPlans.addAll(temp);
                          });
                        }
                        if (meterNameController.text.isNotEmpty) {
                          final temp = await getJobtasks(
                              meterNameController.text,
                              Provider.of<MaximoServerNotifier>(context,
                                      listen: false)
                                  .maximoServerSelected);
                          setState(() {
                            affectedJobPlans.addAll(temp);
                          });
                        }
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.visibility),
                          Text(' Preview Changes'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ))),
                      onPressed: (() {}),
                      child: Row(
                        children: const [
                          Icon(Icons.publish),
                          Text(' Upload Changes'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  // spacer
                  height: 10,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                TextField(
                  controller: meterNameController,
                  decoration: const InputDecoration(
                    labelText: 'Meter Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(
                  // spacer
                  height: 10,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                TextField(
                  controller: oldMeterNameController,
                  decoration: const InputDecoration(
                    labelText: 'Old Meter Name (To Replace)',
                    border: OutlineInputBorder(),
                  ),
                ),
                observationDetails(meterDetails, ''),
                observationDetails(oldMeterDetails, 'Old '),
                const Text('Pm Update Page'),
              ],
            ),
          ),
          const VerticalDivider(
            width: 20,
            thickness: 1,
            indent: 5,
            endIndent: 5,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: affectedJobPlans.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(affectedJobPlans[index].siteid),
                  title: Text(affectedJobPlans[index].jpnum),
                  subtitle: Text(affectedJobPlans[index].description),
                  trailing: Text(affectedJobPlans[index].assetnum),
                );
              },
            ),
          ),
        ],
      ),
      endDrawer: const EndDrawer(),
    );
  }
}

Widget observationDetails(ObservationList? observation, String whichMeter) {
  if (observation == null) {
    return Card(
      child: ExpansionTile(
        title: Text('${whichMeter}Meter'),
        children: const [
          Text(
              'No Meter Entered or Meter cannot be found, please check observation list')
        ],
      ),
    );
  }
  return Card(
    child: ExpansionTile(
      title: Text('${whichMeter}Meter'),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Text(observation.meterGroup),
          title: Text(observation.inspect),
          subtitle: Text('Inspect ${observation.inspect}'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(observation.extendedDescription),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: observation.observations.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(observation.observations[index].code),
              title: Text(observation.observations[index].description),
              subtitle: Text(observation.observations[index].action ?? ''),
            );
          },
        ),
      ],
    ),
  );
}
