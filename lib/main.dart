import 'package:flutter/material.dart';
import 'home.dart';
import 'router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Weather App',
      // home: Home(),
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    );
  }
}
