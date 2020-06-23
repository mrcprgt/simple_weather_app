import 'package:flutter/material.dart';
import 'router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Weather App',
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    );
  }
}
