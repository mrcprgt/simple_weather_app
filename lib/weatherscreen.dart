import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherScreen extends StatefulWidget {
  LatLng data;
  WeatherScreen({Key key, @required this.data}) : super(key: key);
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List jsonDataList = [];
  @override
  void initState() {
    super.initState();
    //Run fetch from API
    fetchDataFromApi(widget.data.latitude, widget.data.longitude)
        .then((value) => jsonDataList = value);
  }

  Future fetchDataFromApi(double lat, double lon) async {
    //Fetch data from the two apis
    var addressCall =
        'https://us1.locationiq.com/v1/reverse.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&lat=$lat&lon=$lon&format=json';

    var weatherCall =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=6b407f53d3c5d6c47816908f08d95c7e';

    //Store the response from locationiq api
    var addressResponse = await http.get(addressCall);

    //Store data in a variable and serialize to list
    var addressJsonData;
    addressJsonData = json.decode(addressResponse.body);
    print(addressJsonData);

    //store data into the variable that holds all of our data from the calls
    jsonDataList.add(addressJsonData);

    //Store the response from openweathermap api
    var weatherResponse = await http.get(weatherCall);

    //Store data in a variable and serialize to list
    var weatherJsonData;
    weatherJsonData = json.decode(weatherResponse.body);
    print(weatherJsonData);

    //store data into the variable that holds all of our data from the calls
    jsonDataList.add(weatherJsonData);

    return jsonDataList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: fetchDataFromApi(widget.data.latitude,
          widget.data.longitude), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SafeArea(
            child: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Please wait its loading...'),
                ],
              ),
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return SafeArea(
              child: Scaffold(
                body: Container(
                  padding: EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text("WEATHER DETAILS"),
                          color: Colors.green,
                        ),
                        Column(
                          children: <Widget>[
                            Text("Weather: " + jsonDataList[1].toString())
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
