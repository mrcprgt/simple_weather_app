import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //FormBuilder Key
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  //For displaying error banner
  bool error = false;

  //Geolocator
  var geolocator = Geolocator();

  //Storing address from form input
  String address;

  //Storing geocode from address input
  var geocodeFromInput;

  //Store coordinates when using currentlocation
  LatLng currentLocation;

  Future<void> _showUseLocationPrompt() async {
    return showDialog<void>(
      useRootNavigator: true,
      context: context,
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

                //Check if location perms is undetermined
                if (status.isUndetermined) {
                  //Request for location
                  Permission.location.request();
                  //Disable dialog
                  Navigator.of(context).pop();
                  //Get current location, store coordinates to variable, send variable to next screen
                  await geolocator
                      .getCurrentPosition()
                      .then((value) => currentLocation =
                          new LatLng(value.latitude, value.longitude))
                      .then((value) => Navigator.of(context)
                          .pushNamed('/mapscreen', arguments: currentLocation));
                }

                //Check if location perms is denied
                if (status.isDenied) {
                  //Show error banner
                  setState(() {
                    error = true;
                  });
                  //Remove dialog
                  Navigator.of(context).pop();
                }

                //If location perms is granted
                if (status.isGranted) {
                  //Get current location, store coordinates to variable, send variable to next screen
                  await geolocator.getCurrentPosition().then((value) =>
                      currentLocation =
                          new LatLng(value.latitude, value.longitude));
                  Navigator.of(context)
                      .pushNamed('/mapscreen', arguments: currentLocation);
                }

                //Check if location perms is permanently denied
                if (status.isPermanentlyDenied) {
                  //Open application settings.
                  openAppSettings();
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
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[100],
        body: Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _fbKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //Error Banner
                  error
                      ? GestureDetector(
                          onTap: () async {
                            if (await Permission.location.isPermanentlyDenied) {
                              openAppSettings();
                            }
                            await Permission.location
                                .request()
                                .whenComplete(() => setState(() {
                                      error = !error;
                                    }));
                          },
                          child: Card(
                              margin: EdgeInsets.all(4),
                              color: Colors.red[300],
                              child: Text(
                                  "Location services is required for this app. Tap here to enable.",
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.black))),
                        )
                      : Container(),
                  Image.asset('assets/bermuda-searching.png',
                      width: MediaQuery.of(context).size.width, height: 300),
                  SizedBox(height: 20),
                  _buildInputCard(),
                  Container(
                    height: 25,
                  ),
                  RaisedButton(
                    color: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Text("Next"),
                    onPressed: () async {
                      _fbKey.currentState.saveAndValidate();

                      //Combine values from textfields and trim leading whitespace
                      address = _fbKey.currentState.value["brgy"].trim() +
                          ", " +
                          _fbKey.currentState.value["city"].trim() +
                          ", " +
                          _fbKey.currentState.value["prov"].trim();

                      print(address);

                      //make an http request
                      var geoCodeQuery =
                          'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&q=$address&format=json';

                      //show progress dialog now
                      await pr.show();

                      if (pr.isShowing()) {
                        var geoCodeQueryResult = await http.get(geoCodeQuery);
                        var jsonData = json.decode(geoCodeQueryResult.body);

                        //if len = 1, user input is blank
                        if (jsonData.length == 1) {
                          pr.hide();
                          _showUseLocationPrompt();
                        }

                        //check if result is in the philippines
                        if (jsonData.first["display_name"]
                                .contains("Philippines") ==
                            false) {
                          pr.hide();
                          _showUseLocationPrompt();
                        } else {
                          //If result is valid -> go to map
                          pr.hide();

                          //send data to map screen
                          geocodeFromInput = new LatLng(
                              double.parse(jsonData.first["lat"]),
                              double.parse(jsonData.first["lon"]));
                          // print(geocodeFromInput.toString());

                          Navigator.of(context).pushNamed('/mapscreen',
                              arguments: geocodeFromInput);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Card _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.all(4),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
          ],
        ),
      ),
    );
  }
}
