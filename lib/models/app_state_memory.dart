import 'package:latlong2/latlong.dart';

class AppStateMemory {
  AppStateMemory(this.lastMapLocation);

  final (LatLng, double)? lastMapLocation;

  factory AppStateMemory.empty() {
    return AppStateMemory(null);
  }

  factory AppStateMemory.fromJson(Map<String, dynamic> json) {
    return AppStateMemory(
      json["lastMapLocation"] != null ? (LatLng(json["lastMapLocation"][0] ?? 0, json["lastMapLocation"][1] ?? 0), json["lastMapLocation"][2] ?? 0) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lastMapLocation": [lastMapLocation?.$1.latitude, lastMapLocation?.$1.longitude, lastMapLocation?.$2],
    };
  }
}
