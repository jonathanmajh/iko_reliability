import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart';

import '../bin/drawer.dart';
import '../bin/end_drawer.dart';
import '../main.dart';

@RoutePage()
class SpareCriticalityPage extends StatefulWidget {
  const SpareCriticalityPage({super.key});

  @override
  State<SpareCriticalityPage> createState() => _SpareCriticalityPageState();
}

class _SpareCriticalityPageState extends State<SpareCriticalityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
      ),
      appBar: AppBar(
        title: const Text('Spare Part Criticality'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
          )
        ],
      ),
      endDrawer: const EndDrawer(),
      body: ElevatedButton(
          child: const Text('Configure'),
          onPressed: () {
            // database!.getSpareParts(
            //   siteid: context.read<SelectedSiteNotifier>().selectedSite,
            //   env: context.read<MaximoServerNotifier>().maximoServerSelected,
            // );
            database!.getPurchases(
              siteid: context.read<SelectedSiteNotifier>().selectedSite,
              env: context.read<MaximoServerNotifier>().maximoServerSelected,
            );
          }),
    );
  }
}
