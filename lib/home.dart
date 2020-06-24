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
  //Variables
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var geolocator = Geolocator();
  String address;
  var geocodeFromInput;
  LatLng currentLocation;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      useRootNavigator: true,
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
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
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
                    Image.asset('assets/bermuda-searching.png',
                        width: MediaQuery.of(context).size.width, height: 300),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: new BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(),

                        //color: Colors.purple,
                        // gradient: new LinearGradient(
                        //   colors: [Colors.blue, Colors.red],
                        // ),
                      ),
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
                    RaisedButton(
                      elevation: 2,
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
                        //  var query =
                        // "street=$addressSplit[0]&city=$addressSplit[1]&country=philippines";
                        // var url =
                        //     'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&$query&format=json';
                        // var addressSplit = address.split(", ");
                        //var url =
                        // 'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&q=$address&countrycodes=<ISO_3166-2:PH>&format=json';

                        //make an http request
                        var geoCodeQuery =
                            'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&q=$address&format=json';
                        // var geoCodeQuery =
                        //     'https://us1.locationiq.com/v1/search.php?key=58c2ebc4fef933&q=$address&format=json';
                        await pr.show();

                        if (pr.isShowing()) {
                          var response = await http.get(geoCodeQuery);

                          var jsonData;
                          jsonData = json.decode(response.body);

                          //if len = 1, user input is blank
                          if (jsonData.length == 1) {
                            pr.hide();
                            _showMyDialog();
                          }

                          //check if the first result is in the philippines
                          if (jsonData.first["display_name"]
                                  .contains("Philippines") ==
                              false) {
                            pr.hide();
                            _showMyDialog();
                          } else {
                            //If result is valid -> go to map
                            pr.hide();
                            geocodeFromInput = new LatLng(
                                double.parse(jsonData.first["lat"]),
                                double.parse(jsonData.first["lon"]));
                            print(geocodeFromInput.toString());

                            Navigator.of(context).pushNamed('/mapscreen',
                                arguments: geocodeFromInput);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
