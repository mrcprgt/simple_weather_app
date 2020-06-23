import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  LatLng data;

  MapScreen({Key key, @required this.data}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  @override
  void initState() {
    super.initState();
    this.markers.add(Marker(markerId: MarkerId("pin"), position: widget.data));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Address"),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            markers: Set.from(markers),
            initialCameraPosition: CameraPosition(
              target: widget.data,
              zoom: 15,
            ),
            zoomControlsEnabled: false,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.keyboard_arrow_right),
          onPressed: () {},
        ),
      ),
    );
  }
}
