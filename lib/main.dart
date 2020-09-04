import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();

  static LatLng _initialPosition = LatLng(0,0);
  static LatLng _currentLocation = LatLng(0,0);
  final Set<Marker> _markers = {};


  @override
  void initState(){
    super.initState();
    _getLocation();
  }

   void _init_location(){
     mapController.animateCamera(
       CameraUpdate.newCameraPosition(
         CameraPosition(
             target: _currentLocation, zoom: 7.0),
       ),
     );
  }

  void _getLocation() async {
    Position position =
    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude.toDouble(),
          position.longitude.toDouble());
    });
    print(_currentLocation.toString());
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    mapController = controller;
    _init_location();
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  MapType _currentMapType = MapType.normal;
  LatLng _lastMapPosition = _initialPosition;
  GoogleMapController mapController;


  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon:   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Location alarm'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: _currentMapType,
              markers: _markers,
              onCameraMove: _onCameraMove,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11.0,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(0),
                child: Align(
                  child: Column(children: <Widget>[
                    FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                    SizedBox(height: 16.0),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                    FloatingActionButton(onPressed: _init_location,
                      child: const Icon(Icons.location_on, size: 36.0),),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}
