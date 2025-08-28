import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/bin/drawer.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';

@RoutePage()
class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const Drawer(
          child: NavDrawer(),
        ),
        appBar: AppBar(
          title: const Text("Item Search & Request"),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
        ),
        endDrawer: const EndDrawer(),
        body: Column(
          children: [Text('HI')],
        ));
  }
}
