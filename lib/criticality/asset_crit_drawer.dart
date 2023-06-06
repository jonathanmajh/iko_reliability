import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:provider/provider.dart';

class AssetCritSettingsDrawer extends StatefulWidget {
  const AssetCritSettingsDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AssetCritSettingsDrawerState();
}

class _AssetCritSettingsDrawerState extends State<AssetCritSettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager = Provider.of<ThemeManager>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: ListTile(
            title: const Text(
              'Asset Criticality Settings',
              style: TextStyle(fontSize: 24),
            ),
            trailing: Switch(
                //true => darkmode on
                value: (themeManager.themeMode == ThemeMode.dark),
                onChanged: (value) {
                  themeManager.toggleTheme(value);
                },
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  return (themeManager.themeMode == ThemeMode.dark)
                      ? const Icon(Icons.dark_mode_rounded)
                      : const Icon(Icons.light_mode_rounded);
                })),
          )),
          ListTile(
            title: const Text('Calculate Risk Priority Numbers (RPN)'),
            trailing: ElevatedButton(
              onPressed: () {/*TODO: calculate rpns in table*/},
              child: const Text('Calculate'),
            ),
          )
        ],
      ),
    );
  }
}
