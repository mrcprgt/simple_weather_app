import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherScreen extends StatefulWidget {
  final LatLng data;
  WeatherScreen({Key key, @required this.data}) : super(key: key);
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _visible = false;
  List<Marker> markers = [];
  List<dynamic> jsonDataList = List(2);
  @override
  void initState() {
    _visible = true;
    super.initState();
    this.markers.add(Marker(markerId: MarkerId("pin"), position: widget.data));
  }

  Future fetchDataFromApi(double lat, double lon) async {
    //Fetch data from the two apis
    var addressCall =
        'https://us1.locationiq.com/v1/reverse.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&lat=$lat&lon=$lon&format=json&limit=1';

    var weatherCall =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=6b407f53d3c5d6c47816908f08d95c7e&units=metric';

    //Store the response from locationiq api
    var addressResponse = await http.get(addressCall);

    //Store data in a variable and serialize to list
    var addressJsonData;
    addressJsonData = json.decode(addressResponse.body);
    print("address data: \n" + addressJsonData.length.toString());
    //addressJsonData = addressJsonData.toList();
    //store data into the variable that holds all of our data from the calls
    jsonDataList[0] = addressJsonData;

    //Store the response from openweathermap api
    var weatherResponse = await http.get(weatherCall);

    //Store data in a variable and serialize to list
    var weatherJsonData;
    weatherJsonData = json.decode(weatherResponse.body);
    print(weatherJsonData);

    //store data into the variable that holds all of our data from the calls
    jsonDataList[1] = weatherJsonData;

    print("JSONDATALIST : \n" + jsonDataList.length.toString());
    return jsonDataList;
  }

  @override
  void dispose() {
    super.dispose();
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
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[_buildAppBar(), _buildWeatherDetails()],
              ),
            );
        }
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //elevation: 5.0,
      //automaticallyImplyLeading: true,
      leading: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: new Material(
              color: Colors.blue[100],
              shape: new CircleBorder(),
              child: Icon(Icons.arrow_back)),
        ),
      ),
      pinned: false,
      floating: true,
      expandedHeight: 300,
      flexibleSpace: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GoogleMap(
            markers: Set.from(markers),
            initialCameraPosition: CameraPosition(
              target: widget.data,
              zoom: 20,
            ),
            zoomControlsEnabled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return SliverFillRemaining(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Text(
                    "Today's Forecast",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  child: Text(
                    "You are here : " + jsonDataList[0]["display_name"],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: _buildMainWeatherCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildMainWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      jsonDataList[1]["weather"][0]["main"].toString(),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      jsonDataList[1]["weather"][0]["description"].toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Image.network(checkIcon(jsonDataList))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Temperature",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  jsonDataList[1]["main"]["temp"].toString() + "°C",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Wind Speed",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  jsonDataList[1]["wind"]["speed"].toString() + " m/sec",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Wind Direction",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  jsonDataList[1]["wind"]["deg"].toString() + " °",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Atmospheric Pressure",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  jsonDataList[1]["main"]["pressure"].toString() + " hPA",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            jsonDataList[1]["clouds"] != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Cloudiness",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        jsonDataList[1]["clouds"]["all"].toString() + "%",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : Container(),
            jsonDataList[1]["rain"] != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Rain in last 1 Hour",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        jsonDataList[1]["rain"]["rain.1h"].toString() + "mm",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Humidity",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  jsonDataList[1]["main"]["humidity"].toString() + "%",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //Check for icons
  String checkIcon(List jsonData) {
    switch (jsonData[1]["weather"][0]["icon"]) {
      case "01d":
        return "http://openweathermap.org/img/wn/01d@4x.png";
        break;
      case "02d":
        return "http://openweathermap.org/img/wn/02d@4x.png";
        break;
      case "03d":
        return "http://openweathermap.org/img/wn/03d@4x.png";
        break;
      case "04d":
        return "http://openweathermap.org/img/wn/04d@4x.png";
        break;
      case "09d":
        return "http://openweathermap.org/img/wn/09d@4x.png";
        break;
      case "10d":
        return "http://openweathermap.org/img/wn/10d@4x.png";
        break;
      case "11d":
        return "http://openweathermap.org/img/wn/11d@4x.png";
        break;
      case "13d":
        return "http://openweathermap.org/img/wn/13d@4x.png";
        break;
      case "50d":
        return "http://openweathermap.org/img/wn/50dd@4x.png";
        break;
      case "01n":
        return "http://openweathermap.org/img/wn/01n@4x.png";
        break;
      case "02n":
        return "http://openweathermap.org/img/wn/02n@4x.png";
        break;
      case "03n":
        return "http://openweathermap.org/img/wn/03n@4x.png";
        break;
      case "04n":
        return "http://openweathermap.org/img/wn/04n@4x.png";
        break;
      case "09n":
        return "http://openweathermap.org/img/wn/09n@4x.png";
        break;
      case "10n":
        return "http://openweathermap.org/img/wn/10n@4x.png";
        break;
      case "11n":
        return "http://openweathermap.org/img/wn/11n@4x.png";
        break;
      case "13n":
        return "http://openweathermap.org/img/wn/13n@4x.png";
        break;
      case "50n":
        return "http://openweathermap.org/img/wn/50n@4x.png";
        break;
      default:
    }
  }
}
