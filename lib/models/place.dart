import 'dart:math';

import 'package:latlong2/latlong.dart';

class Place {
  final String name;
  final String? address;
  final LatLng location;
  final String? notes;

  Place({
    required this.name,
    this.address,
    required this.location,
    this.notes,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['address'],
      location: LatLng(json['latitude'], json['longitude']),
      notes: json['notes'],
    );
  }

  factory Place.random() {
    return Place(
      name: "Random Place ${Random().nextInt(100)}",
      address: "Random Address ${Random().nextInt(100)}",
      location: LatLng(Random().nextInt(180) - 90, Random().nextInt(360) - 180),
      notes: "Some notes",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Place $name | $address | ${location.latitude},${location.longitude} | $notes';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Place) {
      return other.name == name && other.address == address && other.location == location && other.notes == notes;
    }

    return false;
  }

  @override
  int get hashCode => location.hashCode + notes.hashCode;
}
