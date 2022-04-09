import 'package:flutter/material.dart';

class MyTestPage extends StatelessWidget {
  const MyTestPage({Key? key}) : super(key: key);

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
