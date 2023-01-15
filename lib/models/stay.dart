import 'package:flight_deck/models/place.dart';
import 'package:latlong2/latlong.dart';

class Stay {
  final DateTime start;
  final DateTime end;
  final String? notes;
  final List<Place> places;
  final LatLng location;
  final String? name;

  int get stayLength => end.difference(start).inDays;

  Stay({
    required this.start,
    required this.end,
    this.notes,
    required this.location,
    required this.places,
    this.name,
  });

  factory Stay.fromJson(Map<String, dynamic> json) {
    return Stay(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      notes: json['notes'],
      places: (json['places'] as List).map<Place>((e) => Place.fromJson(e)).toList(),
      location: LatLng(json['latitude'], json['longitude']),
      name: json['name'],
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
    };
  }

  @override
  String toString() {
    return 'Stay $name | $start -> $end | ${location.latitude},${location.longitude} | $notes | $places';
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
