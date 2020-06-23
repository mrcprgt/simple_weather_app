import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherScreen extends StatefulWidget {
  LatLng data;
  WeatherScreen({Key key, @required this.data}) : super(key: key);
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[],
            ),
          ),
        ),
      ),
    );
  }
}
