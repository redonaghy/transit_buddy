import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:transit_buddy/dart_gtfs.dart' as dart_gtfs;

void main() async {
  // await dart_gtfs.printClosestBus();
  // dart_gtfs.main();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transit Buddy =)',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Transit Buddy =) Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Future<List<FeedEntity>> futureVehicleList = dart_gtfs.pullClosestBus();
  List<FeedEntity> vehicleList = [];
  List<Marker> mapMarkerList = [];
  String searchResult = "921";

  // Pre-populates map with some hard-coded bus stops
  List<Marker> stopMarkerList = [
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

  updateVehicleLists(Future<List<FeedEntity>> futureVehicleList) {
    futureVehicleList.then((value) {
      vehicleList = [];
      mapMarkerList = [];
      for (FeedEntity vehicle in value) {
        if (vehicle.vehicle.position.latitude != 0 &&
            vehicle.vehicle.position.longitude != 0) {
          vehicleList.add(vehicle);
          mapMarkerList.add(Marker(
            builder: (ctx) => const Icon(Icons.bus_alert),
            point: LatLng(vehicle.vehicle.position.latitude,
                vehicle.vehicle.position.longitude),
          ));
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // Reads future & populates bus list and marker list
    if (searchResult != "") {
      updateVehicleLists(dart_gtfs.pullVehiclesFromRoute(searchResult));
    }

    // Creates a list of vehicleRow objects to display below
    List<Widget> vehicleRowList = [];
    if (vehicleList.isNotEmpty) {
      for (FeedEntity entity in vehicleList) {
        vehicleRowList.add(VehicleRow(busInfo: entity));
      }
    } else {
      vehicleRowList.add(const Text("No buses found : ("));
    }
    debugPrint("vehicleList length: ${vehicleList.length}");

    // Widget code starts here
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              showSearch(
                      context: context,
                      // delegate to customize the search bar
                      delegate: RouteSearchBar())
                  .then(
                (value) {
                  searchResult = value;
                  if (searchResult == "A Line") {
                    searchResult = "921";
                  } else if (searchResult == "Blue Line") {
                    searchResult = "901";
                  } else if (searchResult == "Green Line") {
                    searchResult = "902";
                  }
                },
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(44.93804, -93.16838),
                    zoom: 11,
                  ),
                  nonRotatedChildren: [
                    AttributionWidget.defaultWidget(
                      source: 'OpenStreetMap contributors',
                      onSourceTapped: null,
                    ),
                  ],
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: mapMarkerList + stopMarkerList,
                    ),
                  ]),
            ),
          ],
        ),
      ),
      // floatingActionButton: const FloatingActionButton(
      //   onPressed:() => ,
      //   tooltip: 'Refresh',
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}

/*
This widget returns a single row that contains a bus icon and then text. Currently
it takes a Future<FeedEntity>, and says "Loading..." when data hasn't loaded and
displays bus route and distance when it has loaded.
*/
class VehicleRow extends StatefulWidget {
  const VehicleRow({
    super.key,
    // This is the String parameter that decided the text in the widget.
    required this.busInfo,
  });

  // final Future<FeedEntity> busInfo;
  final FeedEntity busInfo;

  @override
  State<VehicleRow> createState() => _VehicleRowState();
}

class _VehicleRowState extends State<VehicleRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.bus_alert),
          ),
          Text(
              "Route ${widget.busInfo.vehicle.trip.routeId} - ${DistanceHaversine().as(LengthUnit.Meter, LatLng(44.93994, -93.16715), LatLng(widget.busInfo.vehicle.position.latitude, widget.busInfo.vehicle.position.longitude)) / 1000} km away"),
        ],
      ),
    );
  }
}

// This creates the search bar!
class RouteSearchBar extends SearchDelegate {
  // This is where the list of items (routes) need to go
  List<String> searchTerms = [
    "A Line",
    "63",
    "21",
    "74",
    "Blue Line",
    "Green Line",
  ];

  // This one clears the search bar of text when its clicked
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // back arrow to exit search menu :)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // shows query result? still  lil confused by this one
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var route in searchTerms) {
      if (route.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(route);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  // this one shows query results while typing!
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var route in searchTerms) {
      if (route.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(route);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }
}
