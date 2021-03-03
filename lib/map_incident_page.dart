import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIncidentPage extends StatefulWidget {
  @override
  _MapIncidentPageState createState() => _MapIncidentPageState();
}

class _MapIncidentPageState extends State<MapIncidentPage> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(-1.28333, 36.81667),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Incident Location")),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: _currentPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete();
          },
        ),
      ),
    );
  }
}