# TRANSIT BUDDY

A transit tracking app for the Twin Cities which allows you to see route maps and where vehicles are in real time on any given route (excluding Minnesota Valley Transit Authority services).

This is a transit helper for people who know their regular routes and want a quick way to see where the closest bus is, instead of putting in a destination and going through Google/Apple Maps’ process to find route timings. It also acts as a visual aid for people who struggle with time estimates for buses to see how far the bus actually is on a map.

Transit Buddy is a Flutter app; it works on both Android and iOS devices. We get GTFS data from Metro Transit as soon as it updates which is every 15 seconds. So we pull every 15 seconds and use it to live update the bus positions.

# Development
- Install Flutter (https://docs.flutter.dev/get-started/install)
- Install the necessary tools to build to an iOS or Android emulator or mobile device (https://docs.flutter.dev/deployment)
- Launch the app
    - Open the `transit_buddy` folder in Visual Studio Code
    - Open `main.dart`
    - On the bottom right of the VS Code window, you will see text saying Windows or MacOS. Click on it and select the emulator or device that you want to build to
    - Click on the run button (looks like a play arrow on the top right of the window)

# API
- The app uses [GTFS](https://gtfs.org/) realtime data from [Metro Transit](https://svc.metrotransit.org/) for all real-time data updates
- It uses [Metro Transit GTFS static](https://svc.metrotransit.org/mtgtfs/gtfs.zip) data for matching live data to scheduled trips and route diagrams
- These two data sources include routes operated by Metro Transit, the Metropolitan Council, Maple Grove Transit, Plymouth Metrolink, SouthWest Transit, the University of Minnesota, and the Metropolitan Airports Commission (Minnesota Valley Transit Authority is not included and they have their own data feed)

# Known Bugs
- Doesn't work without an active internet connection
- If the app is started without an active internet connection it needs to be restarted with an internet connection in order to work properly
- The markers for trains are incorrect because 
    - they don't have "bearing" in the data (which provides directon data for buses)
    - they use the same icon as the buses instead of the train icon
    - there are directional, train specific, icons in the assets folder intended for fixing this
- The METRO Red Line does not have a shape in "shapes.txt" and therefore does not show the route diagram on the map
- Occasionally, a bus marker will disappear off the map on a 15-sec update and reappear on the next update This is due to momentary lapses in the GTFS data feed for that bus, but it always reappears after a momentary gap!
- Search Bar currently only supports search by route id. User cannot type 'Metro A line' and must type 920 instead. But as of now all routes with special names show up at the top of the list, making it a smaller issue.

![A horrifying image of a Satanic Transit Rat straddling a bus that says Weezer](assets/alt_icon.png)