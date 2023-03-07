import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

String vehicleInfoString(FeedEntity entity) {
  return """Vehicle Information for Vehicle #${entity.vehicle.vehicle.label}
  Vehicle ID: ${entity.id}
  Descriptor: ${entity.vehicle.vehicle.label}
  Route ID : ${entity.vehicle.trip.routeId}
  Latitude: ${entity.vehicle.position.latitude}
  Longitude: ${entity.vehicle.position.longitude}
  Speed: ${entity.vehicle.position.speed}\n\n""";
}

/*
This function currently finds a random A-Line bus and returns a string containing its distance from a bus stop.
I'd like for it to actually return the closest A-Line to the bus stop
*/
Future<String> pullClosestBus() async {
  final url =
      Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
  final response = await http.get(url);

  // response.statusCode == 200 means fetching the protocol buffer was successful
  if (response.statusCode == 200) {
    final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
    // currentLocation is a placeholder location for the Snelling & Grand A-Line bus stop.
    // As a first step we'll just be trying to measure distance from here to the vehicles.
    LatLng currentLocation = LatLng(
        44.93994, -93.16715);
    // feedMessage.entity is a list of FeedEntity objects, which represent the vehicles
    for (final entity in feedMessage.entity) {
      if (entity.vehicle.trip.routeId == "921") {
        // this chunk of code for distanceToBus finds lat/long distance between currentLocation (bus stop)
        // and a single vehicle
        double distanceToBus = DistanceHaversine().as(
                LengthUnit.Meter,
                currentLocation,
                LatLng(entity.vehicle.position.latitude,
                    entity.vehicle.position.longitude)) /
            1000;
        // right now it just makes a string and returns it for the first A-line bus it sees. I'd like for it
        // to do this only for the closest bus. One idea I was thinking was making a map/dictionary where the
        // key is the FeedEntity object (represented as entity in this loop) and the value is the distance,
        // where you can just copy the code above. Then, somehow sorting that dictionary by the values (distance).
        // This task would be more of a data structures thing.
        String output =
            "Route ${entity.vehicle.trip.routeId} - ${distanceToBus} km away";
        
        return Future.delayed(const Duration(seconds: 0), () => output);
      }
    }
    return Future.delayed(const Duration(seconds: 0), () => "Fetch failed");
  }
  return Future.delayed(
      const Duration(seconds: 0), () => "Network connection failed");
}

// Just a function that prints for debugging purposes
Future<void> printClosestBus() async {
  var output = await pullClosestBus();
  print(output);
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
