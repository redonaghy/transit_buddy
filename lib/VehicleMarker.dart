import 'dart:math' as math;
import 'package:flutter/material.dart';

/*
  Graphical element of the vehicle markers placed on the map.
  Contains bus icon and directional arrow
  May change to a stateful widget later so we can modify a marker instead of rebuilding,
  but this is good for now.
*/

class VehicleMarker extends StatelessWidget {
  double angle;

  VehicleMarker({
    super.key,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.directions_bus,
          size: IconThemeData.fallback().size! * 0.85,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        Transform.rotate(
          // Degrees to radian
          angle: angle * math.pi / 180.0,
          child: Image.asset(
            "assets/vehicle_direction.png",
          ),
        )
      ],
    );
  }
}
