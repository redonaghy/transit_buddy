import 'dart:convert';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:latlong2/latlong.dart';

class RouteNode {
  late LatLng ll;
  String order = "";

  RouteNode(String la, String lo, String or) {
    ll = LatLng(double.parse(la), double.parse(lo));
    order = or;
  }
}

/*
Class to handle and retrieve static GTFS data
*/

class StaticData {
  Map<String, List<String>?> routeMap = {};
  Map<String, List<String>> tripMap = {};
  Map<String, List<RouteNode>> shapeMap = {};

  StaticData() {
    // Populate routes
    rootBundle.loadString('assets/routes.txt').then((value) {
      List<String> routeMaster = LineSplitter.split(value).toList();
      for (String line in routeMaster) {
        var lineArray = line.split(",");
        print(lineArray.length);
        routeMap[lineArray[0]] = lineArray.sublist(1);
      }
    });
    // Populate trips
    rootBundle.loadString('assets/trips.txt').then((value) {
      List<String> tripMaster = LineSplitter.split(value).toList();
      for (String line in tripMaster) {
        var lineArray = line.split(",");
        print(lineArray.length);
        tripMap[lineArray[2]] =
            lineArray; // index 2 has trip id which is unique - route ids are not unique in this file
        // also, shape id is index 7
      }
    });
    // shapes!
    rootBundle.loadString('assets/shapes.txt').then((value) {
      List<String> tripMaster = LineSplitter.split(value).toList();
      // String curShapeId =
          // 'initialising'; // adds an initialisation entry to be removed later
      for (int i = 1; i < tripMaster.length; i++) {
        var lineArray = tripMaster[i].split(",");
        RouteNode newShape = RouteNode(lineArray[1], lineArray[2], lineArray[3]);
        shapeMap[lineArray[0]] ??= [];
        shapeMap[lineArray[0]]?.add(newShape);
      }
      // for (String line in tripMaster) {
        // var lineArray = line.split(",");
        // shapeMap.remove(
            // 'initialising'); // removes that first placeholder/initialisation entry
      // }
    });
  }

  /*
    Returns a list of routes, removing the example entry. This is the only place
    where the example entry interferes with code so it is fine.
  */
  List<String> getRoutes() {
    var routeList = routeMap.keys.toList();
    routeList.remove("route_id");
    return routeList;
  }

  /*
    The special lines only have long names. The regular lines only have short names.
    This method returns whichever one is not an empty string
  */
  String getName(String routeId) {
    // Is this code unsafe
    List<String>? route = routeMap[routeId];
    if (route == null) {
      return "";
    } else if (route[1] == "") {
      return route[2];
    } else {
      return route[1];
    }
  }
}
