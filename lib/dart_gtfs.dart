import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

/*
Pulls a list of vehicles pertaining to a Metro Transit route ID, returns as a list
*/
Future<List<FeedEntity>> pullVehiclesFromRoute(String route) async {
  final url =
      Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
  final response = await http.get(url);

  // response.statusCode == 200 means fetching the protocol buffer was successful
  if (response.statusCode == 200) {
    final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
    // feedMessage.entity is a list of FeedEntity objects, which represent the vehicles
    List<FeedEntity> buses = [];
    for (final entity in feedMessage.entity) {
      if (entity.vehicle.trip.routeId == route) {
        buses.add(entity);
      }
    }
    return Future.delayed(const Duration(seconds: 0), () => buses);
  }
  List<FeedEntity> buses = [];
  return Future.delayed(const Duration(seconds: 0), () => buses);
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
