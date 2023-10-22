import 'package:flight_deck/models/place.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapLocation {
  const MapLocation({
    required this.location,
    this.name,
    this.icon,
  });

  final LatLng location;
  final String? name;
  final IconData? icon;

  factory MapLocation.fromPlace(Place place) {
    return MapLocation(
      location: place.location,
      name: place.name,
      icon: Icons.location_on_sharp,
    );
  }

  factory MapLocation.pointOnMap(LatLng location) {
    return MapLocation(
      location: location,
      icon: Icons.location_on_sharp,
    );
  }
}
