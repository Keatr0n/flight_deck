import 'dart:math';

import 'package:latlong2/latlong.dart';

class MapUtils {
  static double getDistance(LatLng point1, LatLng point2) {
    // don't know how this works, I got it from here
    // https://www.movable-type.co.uk/scripts/latlong.html
    const R = 6371e3; // metres
    final deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(point1.latitudeInRad) * cos(point2.latitudeInRad) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // in metres
  }
}
