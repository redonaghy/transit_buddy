import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';
import 'package:transit_buddy/GtfsData.dart';
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
  GtfsData staticDataFetcher = GtfsData();
  List<FeedEntity> vehicleList = [];
  List<Marker> vehicleMarkerList = [];
  String route = "921";
  bool initRun = true;
  late StreamSubscription<List<FeedEntity>> streamListener;
  late LocationData _currentPosition;
  final Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  Widget build(BuildContext context) {
    // Declares the streamListener and refreshes vehicles based on first event
    void startTransitStream() {
      streamListener = dart_gtfs.transitStream().listen((transitFeed) {
        setState(() {
          debugPrint("Refreshed");
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
              debugPrint("${vehicle.vehicle.position.bearing}");
            }
          }
          if(_currentPosition != null) {
            print(_currentPosition.toString());
            vehicleMarkerList.add(Marker(
                builder: (ctx) {
                  return Icon(Icons.currency_bitcoin);
                },
                point: LatLng(_currentPosition.latitude!,
                    _currentPosition.longitude!),
            ));
          }
        });
      });
    }

    void userLocation() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();

    }
    // On first build, the app will subscribe to a stream of transit data that refreshes every 15 seconds
    if (initRun) {
      startTransitStream();
      userLocation();
      initRun = false;
    }

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

    debugPrint("Rebuilding map");
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
            subdomains: ['a', 'b', 'c'],
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
                    // Don't know if there's a more elegant way of doing this, but to switch routes I stop and restart the stream :P
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
