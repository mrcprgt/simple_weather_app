import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Variables
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var geolocator = Geolocator();
  List<Marker> markers = [];

  String address;
  var geocodeFromInput;
  LatLng currentLocation;

  bool pressed = false;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Woops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Can\'t seem to find your location.'),
                Text('Would you like to use your current location?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                var status = await Permission.location.status;
                print(status);
                if (status.isUndetermined) {
                  Permission.location.request();
                  await geolocator
                      .getCurrentPosition()
                      .then((value) => currentLocation =
                          new LatLng(value.latitude, value.longitude))
                      .then((value) => Navigator.of(context)
                          .pushNamed('/mapscreen', arguments: currentLocation));
                }
                if (status.isDenied) {
                  Navigator.of(context).pop();
                }
                if (status.isGranted) {
                  await geolocator.getCurrentPosition().then((value) =>
                      currentLocation =
                          new LatLng(value.latitude, value.longitude));
                  Navigator.of(context)
                      .pushNamed('/mapscreen', arguments: currentLocation);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Simple Weather App'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(16),
                child: FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "brgy",
                        decoration: InputDecoration(labelText: "Barangay"),
                      ),
                      FormBuilderTextField(
                        attribute: "city",
                        decoration: InputDecoration(labelText: "City"),
                      ),
                      FormBuilderTextField(
                        attribute: "prov",
                        decoration: InputDecoration(labelText: "Province"),
                      ),
                      MaterialButton(
                        child: Text("Submit"),
                        onPressed: () async {
                          _fbKey.currentState.saveAndValidate();

                          //Combine values from textfields and trim leading whitespace
                          address = _fbKey.currentState.value["brgy"].trim() +
                              ", " +
                              _fbKey.currentState.value["city"].trim() +
                              ", " +
                              _fbKey.currentState.value["prov"].trim();

                          print(address);
                          // _scaffoldKey.currentState.showSnackBar(new SnackBar(
                          //   duration: new Duration(seconds: 4),
                          //   content: new Row(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     children: <Widget>[
                          //       new CircularProgressIndicator(),
                          //       new Text("Processing Location")
                          //     ],
                          //   ),
                          // ));
                          //make an http request
                          var url =
                              'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&q=$address&format=json';

                          var response = await http.get(url);

                          var jsonData;
                          jsonData = json.decode(response.body);
                          //print("jsonData : " + jsonData.toString());

                          // if (jsonData.containsKey("error")) {
                          if (jsonData.length == 1) {
                            _showMyDialog();
                          } else {
                            geocodeFromInput = new LatLng(
                                double.parse(jsonData.first["lat"]),
                                double.parse(jsonData.first["lon"]));
                            print(geocodeFromInput.toString());

                            setState(() {
                              pressed = true;
                              markers.add(Marker(
                                markerId: MarkerId('pinMarker'),
                                draggable: false,
                                position: geocodeFromInput,
                              ));
                            });

                            Navigator.of(context).pushNamed('/mapscreen',
                                arguments: geocodeFromInput);
                          }
                        },
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
