import 'dart:convert';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

/// Class that pulls and parses static data from metro gtfs feeds
class StaticData {
  // Maps for data from routes.txt, trips.txt, and shapes.txt, formatted as 
  // id -> info
  Map<String, List<String>?> routeMap = {};
  Map<String, List<String>> tripMap = {};
  Map<String, List<LatLng>> shapeMap = {};

  StaticData() {
    // assigns an array of route info to a route id in routeMap
    rootBundle.loadString('assets/routes.txt').then((value) {
      List<String> routeMaster = LineSplitter.split(value).toList();
      for (String line in routeMaster) {
        // creates an array of route info 
        var lineArray = line.split(","); 
        routeMap[lineArray[0]] = lineArray.sublist(1); // lineArray[0] is route id. After is route related info
      }
    });

    // assigns trip info array to trip id in Trip map
    rootBundle.loadString('assets/trips.txt').then((value) {
      List<String> tripMaster = LineSplitter.split(value).toList();
      for (String line in tripMaster) {
        var lineArray = line.split(",");
        tripMap[lineArray[2]] = lineArray; // lineArray[2] is trip id, rest is trip info.
      }
    });

    // Assigns coordinate list to shape id in a dictionary
    rootBundle.loadString('assets/shapes.txt').then((value) {
      List<String> tripMaster = LineSplitter.split(value).toList();
      for (int i = 1; i < tripMaster.length; i++) {
        var lineArray = tripMaster[i].split(",");
        LatLng newNode = // gets coordinates from array entry and stores as a lat long node
            LatLng(double.parse(lineArray[1]), double.parse(lineArray[2]));
        shapeMap[lineArray[0]] ??= []; // if the shape id isn't registered in the map, assign an empty list to it
        shapeMap[lineArray[0]]?.add(newNode); // when it is registered in the map, add the new node to assigned list
      }
    });
  }

  /// Returns a list of each route IDs from routes.txt
  List<String> getRoutes() {
    var routeList = routeMap.keys.toList();
    routeList.remove("route_id"); // removes example id added from the data so it wont show up in search list
    return routeList;
  }

  /// Sets the shape id of a given trip. Each route has a set of trips, which are
  /// variations of their routes.
  String? getShapeId(String tripId) {
      return tripMap[tripId]?[7]; // tripId[7] is shape id.
  }

  /// gets the routes long name if present else returns it short name.
  String getName(String routeId) {
    List<String>? route = routeMap[routeId];
    if (route == null) {
      return "";
    } else if (route[1] == "") {
      return route[2];
    } else {
      return route[1];
    }
  }
  
  /// Returns a list of trip ID's associated with the given route ID
  List<String> getTripsfromRoute(String routeId) {
    List<String> tripIdList = [];
    tripMap.forEach((key, value) {
      if (value[0] == routeId) {
        tripIdList.add(value[2]);
      }
    });
    return tripIdList;
  }

  /// Returns the direction (NB/SB/WB/EB) of a given tripID for use when building 
  /// vehicle icons.
  String? getTripDirection(String tripId) {
    return tripMap[tripId]?[5];
  }

  /// Grabs all unique shape IDs from a list of trip IDs; for use when plotting
  /// routes on the map without duplicates.
  List<String> getUniqueShapesFromTrips(List<String> tripIdList) {
    List<String> shapeIdList = [];
    for (String tripId in tripIdList) {
      String currShapeId = tripMap[tripId]![7];
      if (!shapeIdList.contains(currShapeId)) {
        shapeIdList.add(currShapeId);
      }
    }
    return shapeIdList;
  }

  /// Gets the list of lat long coordinates associated with a given shape ID 
  /// for use when drawing routes on map.
  Polyline getPolyLine(String shapeId) {
    List<LatLng> nodeList = [];
    if (shapeMap[shapeId] != null) {
      nodeList = shapeMap[shapeId]!;
    }
    return Polyline(points: nodeList, strokeWidth: 5, color: Colors.purple);
  }
}
