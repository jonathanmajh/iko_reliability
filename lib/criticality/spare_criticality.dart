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
            database!.getSparePartsMaximo(
              siteid: context.read<SelectedSiteNotifier>().selectedSite,
              env: context.read<MaximoServerNotifier>().maximoServerSelected,
            );
            database!.getPurchasesMaximo(
              siteid: context.read<SelectedSiteNotifier>().selectedSite,
              env: context.read<MaximoServerNotifier>().maximoServerSelected,
            );
          }),
    );
  }
}

class SparePartsLoadingIndicator extends StatefulWidget {
  const SparePartsLoadingIndicator({super.key});

  @override
  State<SparePartsLoadingIndicator> createState() =>
      _SparePartsLoadingIndicatorState();
}

class _SparePartsLoadingIndicatorState
    extends State<SparePartsLoadingIndicator> {
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedSiteNotifier>().selectedSite.isEmpty) {
      return const SiteToggle();
    }
    sparePartLoading(
      siteid: context.read<SelectedSiteNotifier>().selectedSite,
      env: context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    return Text(message);
  }

  Future<void> sparePartLoading(
      {required String siteid, required String env}) async {
    if (loading) {
      // dont load multiple times
      return;
    }
    setState(() {
      loading = true;
    });
    print('running');
    setState(() {
      message = 'Checking spare parts information...';
    });
    final dataCached = await database!.checkSpareParts(siteid: siteid);
    if (!dataCached) {
      try {
        setState(() {
          message = 'Loading spare parts information from Maximo...';
        });
        await database!.getSparePartsMaximo(
          siteid: siteid,
          env: env,
        );
        setState(() {
          message = 'Loading purchasing information from Maximo...';
        });
        await database!.getPurchasesMaximo(
          siteid: siteid,
          env: env,
        );
      } catch (e) {
        setState(() {
          message = e.toString();
        });
        return;
      }
      try {
        setState(() {
          message =
              'Calculating spare part criticality...\nThis step can take significant time';
        });
        await database!.computeSparePartCriticality(siteid: siteid);
      } catch (e) {
        setState(() {
          message = e.toString();
        });
        return;
      }
    }
    context.router.pushNamed("/criticality/spare");
    Navigator.pop(context); // close the drawer
  }
}
