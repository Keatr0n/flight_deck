import 'dart:math';

import 'package:flight_deck/models/place.dart';
import 'package:latlong2/latlong.dart';

class Stay {
  final DateTime start;
  final DateTime end;
  final String? notes;
  final List<Place> places;
  final LatLng location;
  final String? name;

  /// if the date is fixed, it will not be automatically updated unless the user explicitly changes it
  final bool isFixedDate;

  int get stayLength => end.difference(start).inDays;

  Stay({
    required this.start,
    required this.end,
    this.notes,
    required this.location,
    required this.places,
    this.name,
    required this.isFixedDate,
  });

  factory Stay.fromJson(Map<String, dynamic> json) {
    return Stay(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      notes: json['notes'],
      places: (json['places'] as List).map<Place>((e) => Place.fromJson(e)).toList(),
      location: LatLng(json['latitude'], json['longitude']),
      name: json['name'],
      isFixedDate: json['isFixedDate'],
    );
  }

  factory Stay.random() {
    final randStart = DateTime.now().add(Duration(days: Random().nextInt(100)));

    return Stay(
      start: randStart,
      end: randStart.add(Duration(days: Random().nextInt(30))),
      notes: "Some notes",
      location: LatLng((Random().nextInt(180000) - 90000) / 1000, (Random().nextInt(360000) - 180000) / 1000),
      places: [Place.random(), Place.random(), Place.random()],
      name: "Random Stay ${Random().nextInt(100)}",
      isFixedDate: Random().nextBool(),
    );
  }

  factory Stay.empty() {
    return Stay(
      start: DateTime.now(),
      end: DateTime.now(),
      location: LatLng(0, 0),
      places: [],
      isFixedDate: false,
    );
  }

  Stay copyWith({
    DateTime? start,
    DateTime? end,
    String? notes,
    List<Place>? places,
    LatLng? location,
    String? name,
    bool? isFixedDate,
  }) {
    return Stay(
      start: start ?? this.start,
      end: end ?? this.end,
      notes: notes ?? this.notes,
      places: places ?? this.places,
      location: location ?? this.location,
      name: name ?? this.name,
      isFixedDate: isFixedDate ?? this.isFixedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'notes': notes,
      'places': places.map((e) => e.toJson()).toList(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'name': name,
      'isFixedDate': isFixedDate,
    };
  }

  @override
  String toString() {
    return 'Stay $name | $start -> $end | ${isFixedDate ? "with fixed dates" : "without fixed dates"} | ${location.latitude},${location.longitude} | $notes | $places';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Stay) {
      return other.start == start && other.end == end && other.notes == notes && other.places.length == places.length && other.location == location;
    }

    return false;
  }

  @override
  int get hashCode => start.hashCode + end.hashCode + notes.hashCode + places.hashCode + location.hashCode;
}
