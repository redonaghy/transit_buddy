import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';
import 'package:transit_buddy/dart_gtfs.dart' as dart_gtfs;
import 'package:transit_buddy/RouteSearchBar.dart';

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
  List<FeedEntity> vehicleList = [];
  List<Marker> vehicleMarkerList = [];
  String route = "921";
  bool initRun = true;
  late StreamSubscription<List<FeedEntity>> streamListener;

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
                builder: (ctx) => const Icon(Icons.directions_bus),
                point: LatLng(vehicle.vehicle.position.latitude,
                    vehicle.vehicle.position.longitude),
              ));
            }
          }
        });
      });
    }

    // On first build, the app will subscribe to a stream of transit data that refreshes every 15 seconds
    if (initRun) {
      startTransitStream();
      initRun = false;
    }

    var stopMarkerList = <Marker>[
      Marker(
        builder: (ctx) => Image.asset('assets/bus-stop.png'),
        point: LatLng(44.940063, -93.167231),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/bus-stop.png'),
        point: LatLng(44.940139, -93.167496),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/bus-stop.png'),
        point: LatLng(44.939766, -93.167117),
      ),
      Marker(
        builder: (ctx) => Image.asset('assets/bus-stop.png'),
        point: LatLng(44.939760, -93.166927),
      ),
    ];

    debugPrint("Rebuilding map");
    // App interface
    return Scaffold(
      body: Center(
        child: Container(
          child: Stack(
            children:[
              Flexible(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(44.93804, -93.16838),
                    zoom: 11,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                        'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: vehicleMarkerList + stopMarkerList
                    ),
                  ],
                )
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 55),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    showSearch(context: context, delegate: RouteSearchBar()).then(
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
                  child: Text("Current Route: " + route,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                  )
                ),
              )
            ]
          )
        )
      ),
    );
  }
}
