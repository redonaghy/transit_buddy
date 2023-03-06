import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
        primarySwatch: Colors.green,
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              height: 400,
              child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(44.93804, -93.16838),
                    zoom: 13,
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
                    MarkerLayer(markers: [
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
                    ])
                  ]),
            ),
            Column(
              children: <Widget>[BusWidget()],
              mainAxisAlignment: MainAxisAlignment.end,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/*
* This widget is the block at the bottom that will hold bus info.
* Currently, it only takes a string for a single bus and populates a VehicleRow with that string.
*
*/
class BusWidget extends StatefulWidget {
  const BusWidget({super.key});

  @override
  State<BusWidget> createState() => _BusWidgetState();
}

class _BusWidgetState extends State<BusWidget> {
  final Future<String> busOutput = dart_gtfs.pullClosestBus();

  @override
  Widget build(BuildContext context) {
    // A FutureBuilder is a widget that displays one widget if there is currently
    // output from a Future object (our bus data that takes a second to load), and
    // another widget if there is not (loading icon, for example)
    return FutureBuilder<String>(
      future: busOutput,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          // snapshot.data is the string returned from dart_gtfs.pullClosestBus()
          children = <Widget>[VehicleRow(busInfo: snapshot.data!)];
        } else {
          // "No data found" is shown when the data from dart_gtfs.pullClosestBus()
          // has not been retrieved from the internet yet
          children = <Widget>[
            VehicleRow(
              busInfo: "No data found",
            )
          ];
        }
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ));
      },
    );
  }
}

/*
* This widget returns a single row that contains a bus icon and then text. Currently it only
* takes a single String parameter and puts this into the text object.
*
*/
class VehicleRow extends StatefulWidget {
  const VehicleRow({
    super.key,
    required this.busInfo,
  });

  final String busInfo;

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.bus_alert),
          ),
          Text(widget.busInfo)
        ],
      ),
    );
  }
}
