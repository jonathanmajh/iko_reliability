import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/route.gr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _appRouter = AppRouter();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class GHFlutter extends StatefulWidget {
  const GHFlutter({Key? key}) : super(key: key);

  @override
  State<GHFlutter> createState() => _GHFlutterState();
}

class _GHFlutterState extends State<GHFlutter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("app title"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.message),
                title: Text('Home'),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Test'),
                onTap: () {
                  context.router.pushNamed("/test");
                  // change app state...
                  Navigator.pop(context); // close the drawer
                },
              ),
              ExpansionTile(
                title: const Text("Request PMs"),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Assets'),
                    onTap: () {
                      context.router.pushNamed("/asset");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Maximo Admin"),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Validate PMs'),
                    onTap: () {
                      context.router.pushNamed("/pm/check");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Create Assets'),
                    onTap: () {
                      context.router.pushNamed("/asset");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Create Contractors'),
                    onTap: () {
                      context.router.pushNamed("/contractor");
                      // change app state...
                      Navigator.pop(context); // close the drawer
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        body: ListView(children: const <Widget>[
          ListTile(
            // a spacer
            title: Text(
                'Open the menu on the right, then select a module to get started'),
          )
        ]));
  }
}
