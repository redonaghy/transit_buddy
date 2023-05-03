import 'package:flutter/material.dart';
import 'package:transit_buddy/StaticData.dart';

/// Search menu for selecting routes in transit buddy
class RouteSearchBar extends SearchDelegate {
  List<String> searchTerms = []; // contains routes 
  late StaticData staticData;

  RouteSearchBar(StaticData inputData) {
    staticData = inputData;
    searchTerms = staticData.getRoutes();
  }

  /// Clears the search bar of text when its clicked
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

  /// back arrow to exit search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  /// builds a visual list of search terms for the search menu
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

  /// Filters visual list of current routes based on current user input in search bar
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
