import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A class that contains helper methods for parsing data from gtfs static
/// feeds which contain info like current routes and their associated trips
/// and feeds as well as schedules.
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
  /// 
  /// Each feed entity has an associated route ID that can be used to identify
  /// which route the bys is currently on. For example, if a feed entity had 
  /// the route ID, 921, that would signify that bus is on the A-Line.  
  List<String> getRoutes() {
    var routeList = routeMap.keys.toList();
    routeList.remove("route_id"); // removes example id added from the data so it wont show up in search list
    return routeList;
  }

  /// Gets the shape ID of a given trip. 
  /// 
  /// Shape IDs are used to identify which set of coordinates a trip is 
  /// associated with so a path can be drawn for it. Routes can have multiple
  /// variations, referred to as trips, and each trip has its own shape ID.
  String? getShapeId(String tripId) {
      return tripMap[tripId]?[7]; // tripId[7] is shape id.
  }

  /// Gets the routes long name if present else returns it short name.
  /// 
  /// Most routes do not have a name, and are referred to as their route ID 
  /// (short name). For example, route 63 is commonly referred to as "the 63." 
  /// However some special routes, such as route 921, have a long name (here, 
  /// the A-Line).
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
  
  /// Gets the list of lat long coordinates associated with a given shape ID 
  /// as a Polyline.
  /// 
  /// This can then be drawn on the map to show trip shapes.
  Polyline getPolyLine(String shapeId) {
    List<LatLng> nodeList = [];
    if (shapeMap[shapeId] != null) {
      nodeList = shapeMap[shapeId]!;
    }
    return Polyline(points: nodeList, strokeWidth: 5, color: Colors.purple);
  }
}
