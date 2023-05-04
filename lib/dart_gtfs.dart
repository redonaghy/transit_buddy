import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';

/// When called, this function establishes a connection to the metro transit 
/// gtfs feed and will continuously pull feed messages from the server until 
/// the stream is closed. 
/// 
/// Feed messages are lists of feed entities, the entities themselves contain 
/// information about a single bus that is currently running in the network. 
/// These entities can be used to extract data such as vehicle positions. 
/// 
/// Example:
/// 
/// ```
/// // get all A Line Buses and Put in a list
/// List<FeedEntity> aLineBuses = [];
/// streamListener = dart_gtfs.transitStream().listen((transitFeed) {
///   aLineBuses = []; // reset list
///   for (FeedEntity vehicle in transitFeed) {
///     if (vehicle.vehicle.routeID == "921") {
///       aLineBuses.add(vehicle);
///     }
///   }
/// }
/// ```
Stream<List<FeedEntity>> transitStream() async* {
  while (true) {
    final url =
        Uri.parse('https://svc.metrotransit.org/mtgtfs/vehiclepositions.pb');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);
      yield feedMessage.entity;
      await Future.delayed(const Duration(seconds: 15));
    } else {
      yield <FeedEntity>[];
      await Future.delayed(const Duration(seconds: 15));
    }
  }
}
