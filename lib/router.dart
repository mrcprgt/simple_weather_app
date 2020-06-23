import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simple_weather_app/home.dart';
import 'package:simple_weather_app/weatherscreen.dart';
import 'mapscreen.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
        break;
      case '/mapscreen':
        if (args is LatLng) {
          return MaterialPageRoute(
            builder: (_) => MapScreen(
              data: args,
            ),
          );
        }
        break;

      case '/weatherscreen':
        if (args is LatLng) {
          return MaterialPageRoute(
            builder: (_) => WeatherScreen(
              data: args,
            ),
          );
        }
        break;
    }
  }
}
