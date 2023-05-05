import 'dart:math' as math;
import 'package:flutter/material.dart';

/// This class is used to build bus icons with direction arrows that correlate
/// to the given live bus's bearing by stacking a dynamic arrow on top of a bus icon.
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
