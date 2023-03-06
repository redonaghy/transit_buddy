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

Future<String> pullClosestBus() async {
  final url =
      Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
    LatLng currentLocation = LatLng(
        44.93994, -93.16715); // Placeholder: Snelling & Grand A Line Bus Stop
    for (final entity in feedMessage.entity) {
      if (entity.vehicle.trip.routeId == "921") {
        double distanceToBus = DistanceVincenty().as(
                LengthUnit.Meter,
                currentLocation,
                LatLng(entity.vehicle.position.latitude,
                    entity.vehicle.position.longitude)) /
            1000;
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

Future<void> printClosestBus() async {
  var output = await pullClosestBus();
  print(output);
}

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
