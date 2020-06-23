import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Simple Weather App'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: "Barangay"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
