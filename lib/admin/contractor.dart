import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ContractorPage extends StatelessWidget {
  const ContractorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("test page title"),
      ),
      body: const Center(
          child: Text(
        'Hello World',
      )),
    );
  }
}
