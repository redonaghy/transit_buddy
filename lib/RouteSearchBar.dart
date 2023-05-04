import 'package:flutter/material.dart';
import 'package:transit_buddy/StaticData.dart';

/// Search menu that is entered when user clicks the select route button on the
/// top of the screen. From this menu, users can search for a route and select
/// it to change the filter on the map to buses on that route.
class RouteSearchBar extends SearchDelegate {
  List<String> searchTerms = []; // contains routes 
  late StaticData staticData;

  RouteSearchBar(StaticData inputData) {
    staticData = inputData;
    searchTerms = staticData.getRoutes();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  /// Back arrow for search menu that returns the user to the main screen
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var route in searchTerms) {
      if (route.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(route);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(staticData.getName(result)),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var route in searchTerms) {
      if (route.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(route);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(staticData.getName(result)),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }
}
