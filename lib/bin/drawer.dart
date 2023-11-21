import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../criticality/spare_criticality.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IKO Reliability Maximo',
              style: TextStyle(
                // color: Colors.white,
                fontSize: 24,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.router.pushNamed("/");
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
                context.router.pushNamed("/criticality/system");
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Asset Criticality'),
              onTap: () {
                context.router.pushNamed("/criticality/asset");
                Navigator.pop(context); // close the drawer
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
          ],
        ),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text("Maximo Admin"),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Validate PMs'),
              onTap: () {
                context.router.pushNamed("/pm/check");
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Update PM Meters'),
              onTap: () {
                context.router.pushNamed("/pm/update-meter");
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Create Assets'),
              onTap: () {
                context.router.pushNamed("/asset");
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Create Contractors'),
              onTap: () {
                context.router.pushNamed("/contractor");
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Generate Timesheets'),
              onTap: () {
                context.router.pushNamed("/timesheet");
                // change app state...
                Navigator.pop(context); // close the drawer
              },
            ),
          ],
        )
      ],
    );
  }
}
