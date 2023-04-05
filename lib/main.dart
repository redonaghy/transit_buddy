import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';
import 'package:transit_buddy_alternate/dart_gtfs.dart' as dart_gtfs;
import 'package:transit_buddy_alternate/RouteSearchBar.dart';

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

  @override
  Widget build(BuildContext context) {
    if (initRun) {
      dart_gtfs.pullVehiclesFromRoute(route).then((value) {
        setState(() {
          vehicleList = [];
          vehicleMarkerList = [];
          for (FeedEntity vehicle in value) {
            if (vehicle.vehicle.position.latitude != 0 &&
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
      // If this is commented then build method will run infinitely
      // initRun = false;
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
              child: Column(children: [
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
            MarkerLayer(markers: vehicleMarkerList + stopMarkerList),
          ],
        ))
      ]))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(context: context, delegate: RouteSearchBar()).then(
            (result) {
              setState(() {
                if (result != null) route = result;
              });
            },
          );
        },
        tooltip: 'Search',
        child: Text(route),
      ),
    );
  }
}
