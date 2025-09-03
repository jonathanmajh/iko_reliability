import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart';

import '../criticality/asset_criticality.dart';
import '../criticality/spare_criticality.dart';
import '../criticality/system_criticality.dart';

/// Widget for the left-side navigation drawer of the app.
class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsNotifier settingsNotifier =
        Provider.of<SettingsNotifier>(context, listen: true);
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            padding: EdgeInsetsGeometry.fromLTRB(0, 16, 0, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text(
                    style: TextStyle(fontSize: 24),
                    'IKO Reliability Tool',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    context.router.replacePath("/");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
              ],
            )),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text("Criticality"),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System Criticality'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text('Loading...'),
                        content: SystemLoadingIndicator(),
                      );
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Asset Criticality'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text('Loading...'),
                        content: AssetCriticalityLoadingIndicator(),
                      );
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Spare Part Criticality'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text('Loading...'),
                        content: SparePartsLoadingIndicator(),
                      );
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Item Tool'),
              onTap: () {
                context.router.replacePath("/item");
                // change app state...
                Navigator.pop(context); // close the drawer
              },
            ),
          ],
        ),
        settingsNotifier.isAdmin
            ? ExpansionTile(
                initiallyExpanded: true,
                title: const Text("Maximo Admin"),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit_calendar),
                    title: const Text('Validate PMs'),
                    onTap: () {
                      context.router.replacePath("/pm/check");
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.precision_manufacturing),
                    title: const Text('Create Assets'),
                    onTap: () {
                      context.router.replacePath("/asset");
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.punch_clock),
                    title: const Text('Generate Timesheets'),
                    onTap: () {
                      context.router.replacePath("/timesheet");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warehouse),
                    title: const Text('Item Tool'),
                    onTap: () {
                      context.router.replacePath("/item");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                ],
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
