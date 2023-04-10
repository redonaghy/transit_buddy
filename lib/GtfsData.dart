import 'dart:convert';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;

/*
Class to handle and retrieve static GTFS data
*/

class GtfsData {
  Map<String, List<String>?> routeMap = {};

  GtfsData() {
    // Populate routes
    rootBundle.loadString('assets/routes.txt').then((value) {
      List<String> routeMaster = LineSplitter.split(value).toList();
      for (String line in routeMaster) {
        var lineArray = line.split(",");
        print(lineArray.length);
        routeMap[lineArray[0]] = lineArray.sublist(1);
      }
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
