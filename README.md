# TRANSIT BUDDY

A transit tracking app for the Twin Cities which allows you to see route maps and where vehicles are in real time on any given route (excluding Minnesota Valley Transit Authority services).

# Development
- Install Flutter (https://docs.flutter.dev/get-started/install)
- Install the necessary tools to build to an iOS or Android emulator or mobile device (https://docs.flutter.dev/deployment)
- Run/build the app from the "main.dart" file

# API
- GTFS is used for all real-time data (Metro Transit GTFS data feeds are located near the bottom of the page: https://svc.metrotransit.org/)
- Static data is used for matching live data to scheduled trips and route diagrams (https://svc.metrotransit.org/mtgtfs/gtfs.zip)
- The above data includes routes operated by Metro Transit, the Metropolitan Council, Maple Grove Transit, Plymouth Metrolink, SouthWest Transit, the University of Minnesota, and the Metropolitan Airports Commission (Minnesota Velley Transit Authority is not included and they have their own data feed)

# Known Bugs
- Doesn't work without an active internet connection
- If the app is started without an active internet connection it needs to be restarted with an internet connection in order to work properly
- The direction marker for trains is incorrect because they don't have "bearing" in the data (which provides directon data for buses)
- The METRO Red Line does not have a shape in "shapes.txt" and therefore does not show the route diagram on the map