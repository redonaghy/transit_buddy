import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

/*
Stream of FeedEntity (vehicle) list that sends out data every 15 seconds
*/
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
