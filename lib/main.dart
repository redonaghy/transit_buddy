// dart
import 'dart:async';
import 'package:flutter/material.dart'; // material style widgets

// plugins
import 'package:flutter_map/plugin_api.dart'; // flutter map api package
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart'; // location icon
import 'package:geolocator/geolocator.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart'; // read gtfs data
import 'package:latlong2/latlong.dart';

// our stuff
import 'package:transit_buddy/StaticData.dart';
import 'package:transit_buddy/dart_gtfs.dart' as dart_gtfs;
import 'package:transit_buddy/RouteSearchBar.dart';
import 'package:transit_buddy/VehicleMarker.dart';

void main() async {
  // perform location check before building the app to avoid two location 
  // checks running at the same time
  WidgetsFlutterBinding.ensureInitialized();
  if (await Geolocator.checkPermission() == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }

  runApp(MaterialApp(
    home: TransitApp(),
  ));
}

class TransitApp extends StatefulWidget {
  @override
  State<TransitApp> createState() => _TransitAppState();
}

class _TransitAppState extends State<TransitApp> {
  StaticData staticDataFetcher = StaticData();
  List<FeedEntity> vehicleList = [];
  List<Marker> vehicleMarkerList = [];
  List<Polyline> polyLineList = [];
  List<String> shapeIdList = [];
  String route = "921"; // route default on open is the A-Line (921)

  // Gtfs feed reader, declared as late as is this field will be null on initialization
  late StreamSubscription<List<FeedEntity>> streamListener; 

  /// Pulls and reads gtfs feed for the first time and initializes a stream listener 
  /// that continuously pulls every 15 seconds while the app is running.
  void startTransitStream() {
    streamListener = dart_gtfs.transitStream().listen((transitFeed) {
      setState(() {
        // refresh lists to avoid duplicate data from previous calls.
        vehicleList = []; 
        vehicleMarkerList = [];
        polyLineList = [];
        shapeIdList = [];

        for (FeedEntity vehicle in transitFeed) {
          if (vehicle.vehicle.trip.routeId == route && // is bus on currently selected route
              vehicle.vehicle.position.latitude != 0 &&
              vehicle.vehicle.position.longitude != 0) { // is bus reporting its location correctly
            vehicleList.add(vehicle);
            vehicleMarkerList.add(Marker ( // generate map marker for vehicle based on baring and set it to its current pos
                builder: (ctx) {
                  return VehicleMarker(angle: vehicle.vehicle.position.bearing);
                },
                point: LatLng(vehicle.vehicle.position.latitude,
                    vehicle.vehicle.position.longitude),
              )
            );

            // this will get and draw the current route shape on the map if it isn't there already
            String? vehicleShapeId =
                staticDataFetcher.getShapeId(vehicle.vehicle.trip.tripId);
            if (vehicleShapeId != null &&
                !shapeIdList.contains(vehicle.shape.shapeId)) {
              shapeIdList.add(vehicleShapeId);
              polyLineList.add(staticDataFetcher.getPolyLine(vehicleShapeId));
            }
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTransitStream();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> stopMarkerList = [];

    // App interface
    return Scaffold(
      body: Stack(children: [

        FlutterMap (
          options: MapOptions(
            center: LatLng(44.93804, -93.16838),
            maxZoom: 18,
            zoom: 11,
            rotationThreshold: 60,
            maxBounds: LatLngBounds(
                LatLng(45.423272, -93.961313), LatLng(44.595736, -92.668792)),
            rotationWinGestures: 90,
          ),
          children: [
            TileLayer( // shows map tiles
              urlTemplate: // url for map tile images
                  'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            PolylineLayer( // shows route shapes
              polylines: polyLineList
            ),
            MarkerLayer( // shows bus and stop markers
              markers: vehicleMarkerList + stopMarkerList
            ),
            CurrentLocationLayer(), // shows location icon
          ],
        ),

        // route selector 
        Container (
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 55),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () { // switches screen to search menu when route selector is pressed
              showSearch(
                  context: context,
                  delegate: RouteSearchBar(staticDataFetcher)
                ).then( (result) {
                  setState(() { // changes selected route if new route is pressed in search menu
                    if (result != null) {
                      route = result;
                      streamListener.cancel();
                      startTransitStream();
                    }
                  });
                },
              );
            },
            style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size.fromHeight(40),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
            child: Text(
              "Current Route: ${staticDataFetcher.getName(route)}",
              style: TextStyle(color: Colors.black54, fontSize: 20),
            ),
          ),
        ),
      ]),
    );
  }
}
