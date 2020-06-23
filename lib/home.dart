import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Variables
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String address;
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

                        //make an http request
                        var url =
                            'https://us1.locationiq.com/v1/search.php?key=pk.03ce5820ab6a126c25d2e02370c966fd&q=$address&format=json&matchquality=[0|1]';
                        var response = await http.post(url);
                        //print('Response status: ${response.statusCode}');
                        var jsonData = response.body;
                        var parsedJson = json.decode(jsonData);
                        print('${parsedJson.runtimeType} : $parsedJson');
                        print(parsedJson[0]["lat"]);
                        print(parsedJson[0]["matchcode"]);
                      },
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
