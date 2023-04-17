import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';
import 'package:transit_buddy/StaticData.dart';
import 'package:transit_buddy/dart_gtfs.dart' as dart_gtfs;
import 'package:transit_buddy/RouteSearchBar.dart';
import 'package:transit_buddy/VehicleMarker.dart';
import 'package:location/location.dart';

void main() {
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
  String route = "921";
  bool initRun = true;
  late StreamSubscription<List<FeedEntity>> streamListener;
  late LocationData _currentPosition;
  final Location location = Location();
  bool isLocationPresent = false;

  @override
  Widget build(BuildContext context) {

    // Method to pull userLocation
    void userLocation() async {
      bool locationServiceEnabled;
      PermissionStatus locationPermissionGranted;

      locationServiceEnabled = await location.serviceEnabled();
      if (!locationServiceEnabled) {
        locationServiceEnabled = await location.requestService();
        if (!locationServiceEnabled) {
          return;
        }
      }
      locationPermissionGranted = await location.hasPermission();
      if (locationPermissionGranted == PermissionStatus.denied) {
        locationPermissionGranted = await location.requestPermission();
        if (locationPermissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      location.getLocation().then((value) {
        _currentPosition = value;
        isLocationPresent = true;   
      });
    }

    // Declares the streamListener and refreshes vehicles based on first event
    void startTransitStream() {
      streamListener = dart_gtfs.transitStream().listen((transitFeed) {
        setState(() {
          debugPrint("Refreshed");
          userLocation();
          vehicleList = [];
          vehicleMarkerList = [];
          for (FeedEntity vehicle in transitFeed) {
            if (vehicle.vehicle.trip.routeId == route &&
                vehicle.vehicle.position.latitude != 0 &&
                vehicle.vehicle.position.longitude != 0) {
              vehicleList.add(vehicle);
              vehicleMarkerList.add(Marker(
                builder: (ctx) {
                  return VehicleMarker(angle: vehicle.vehicle.position.bearing);
                },
                point: LatLng(vehicle.vehicle.position.latitude,
                    vehicle.vehicle.position.longitude),
              ));
            }
          }
          
          if (isLocationPresent) {
            vehicleMarkerList.add( Marker(
                builder: (ctx) {
                  return Icon(Icons.my_location);
                },
                point: LatLng(_currentPosition.latitude!,
                    _currentPosition.longitude!),
            ));
          }
        });
      });
    }


    // On first build, the app will subscribe to a stream of transit data that refreshes every 15 seconds
    if (initRun) {
      startTransitStream();
      userLocation();
      initRun = false;
    }

    // ! change to static parsed data at some point
    var stopMarkerList = <Marker>[
      Marker(
        builder: (ctx) => Image.asset('assets/stop-bus.png'),
        point: LatLng(44.940063, -93.167231),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/stop-bus.png'),
        point: LatLng(44.940139, -93.167496),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/stop-bus.png'),
        point: LatLng(44.939766, -93.167117),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/stop-bus.png'),
        point: LatLng(44.939760, -93.166927),
      ),
    ];

    // App interface
    return Scaffold(
        body: Stack(children: [
      FlutterMap(
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
          TileLayer(
            urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: vehicleMarkerList + stopMarkerList),
        ],
      ),
      Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 55),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          onPressed: () {
            showSearch(
                    context: context,
                    delegate: RouteSearchBar(staticDataFetcher))
                .then(
              (result) {
                setState(() {
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
      )
    ]));
  }
}
