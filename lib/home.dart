import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
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
                      onPressed: () {
                        if (_fbKey.currentState.saveAndValidate()) {
                          print(_fbKey.currentState.value);
                        }
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
