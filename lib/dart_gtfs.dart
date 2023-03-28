import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

void getRoutes() async {
  final staticFeedUrl = Uri.parse("https://svc.metrotransit.org/mtgtfs/gtfs.zip");
  final response = await http.get(staticFeedUrl);
  
  if (response.statusCode == 200) {
    final decoder = ZipDecoder();
    
    final zip = decoder.decodeBuffer(InputStream(response.bodyBytes));
    var routes = zip.findFile("routes.txt");
    if (routes != null && routes.isFile) {
      print(routes.rawContent);
    }
  }
}

/*
This function currently finds a random A-Line bus and returns a string containing its distance from a bus stop.
I'd like for it to actually return the closest A-Line to the bus stop
*/
Future<List<FeedEntity>> pullClosestBus() async {
  final url =
      Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
  final response = await http.get(url);

  // response.statusCode == 200 means fetching the protocol buffer was successful
  if (response.statusCode == 200) {
    final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
    // This is our hard-coded example bus stop to check distances with.
    LatLng currentLocation = LatLng(44.93994, -93.16715);
    // feedMessage.entity is a list of FeedEntity objects, which represent the vehicles
    List<FeedEntity> buses = [];
    for (final entity in feedMessage.entity) {
      if (entity.vehicle.trip.routeId == "921") {
        // Right now, the function actually just returns the first A-Line it finds,
        // not the closest one. This is where the code would go that adds all
        // the A-Lines in a list. Then after the for loop, it would get sorted
        // by distance to the bus stop. Ideas for doing this could be using Lists's
        // .sort method and comparing by distance, or putting the entities into
        // a dictionary with key entity and value distance and sorting by distance.\
        buses.add(entity);
      }
    }
    return Future.delayed(const Duration(seconds: 0), () => buses);
    // return Future.delayed(const Duration(seconds: 0), () => "Fetch failed");

    // These bottom two return statements are potential problems. Basically if the
    // http request fails (no connection) I STILL have to return a FeedEntity (vehicle),
    // bc thats the return type and I think Flutter won't like returning null, so
    // I'm currently just returning a fake FeedEntity with id null. Might want to change
    // this down the line cause it might result in "ghost" buses at latlong 0,0 if
    // a network request fails which would be weird.
    // return Future.delayed(
    //     const Duration(seconds: 0), () => FeedEntity(id: "NULL"));
  }
  List<FeedEntity> buses = [];
  return Future.delayed(const Duration(seconds: 0), () => buses);
}

// Just a function that prints for debugging purposes
Future<void> printClosestBus() async {
  var output = await pullClosestBus();
  // print(output);
}

// Left over code from first attempting the HTTP request. Keeping this for now just for educational purposes.
void main() async {
  // HTTP Request
  final url =
      Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Code after successful HTTP request
    final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
    // print('Number of entities: ${feedMessage.entity.length}.');

    // var aLineOutput = File('current_aline_info.txt');
    // var sink = aLineOutput.openWrite();

    // for (final entity in feedMessage.entity) {
    //   if (entity.vehicle.trip.routeId == "921") {
    //     sink.write(vehicleInfoString(entity));
    //   }
    // }

    var map = feedMessage.writeToJsonMap();
    print(map["1"]);

    // sink.close();
    // print(vehicleInfoString(feedMessage.entity.elementAt(1)));
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}
