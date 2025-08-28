import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';
import 'package:iko_reliability_flutter/notifiers/maximo_server_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart';

class ItemLoadingIndivator extends StatefulWidget {
  const ItemLoadingIndivator({super.key});

  @override
  State<ItemLoadingIndivator> createState() => _ItemLoadingIndivatorState();
}

class _ItemLoadingIndivatorState extends State<ItemLoadingIndivator> {
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedSiteNotifier>().selectedSite.isEmpty) {
      return const SiteToggle();
    }
    itemLoading(
      env: context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    return Text(message);
  }

  Future<void> itemLoading({required String env}) async {
    if (loading) {
      // dont load multiple times
      return;
    }
    setState(() {
      loading = true;
    });
  }
}
