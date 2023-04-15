import 'package:flutter/material.dart';
import 'package:transit_buddy/StaticData.dart';

class RouteSearchBar extends SearchDelegate {

  // This is where the list of items (routes) need to go
  List<String> searchTerms = [];
  late StaticData staticData;

  RouteSearchBar(StaticData inputData) {
    staticData = inputData;
    searchTerms = staticData.getRoutes();
  }

  // This one clears the search bar of text when its clicked
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

  // back arrow to exit search menu :)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // shows query result? still  lil confused by this one
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

  // this one shows query results while typing!
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
