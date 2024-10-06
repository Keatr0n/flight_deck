import 'package:latlong2/latlong.dart';

enum AirportType {
  largeAirport,
  mediumAirport,
  smallAirport,
  seaplaneBase,
  heliport,
  balloonport,
  closed;

  String get name {
    switch (this) {
      case AirportType.largeAirport:
        return "Large Airport";
      case AirportType.mediumAirport:
        return "Medium Airport";
      case AirportType.smallAirport:
        return "Small Airport";
      case AirportType.seaplaneBase:
        return "Seaplane Base";
      case AirportType.heliport:
        return "Heliport";
      case AirportType.balloonport:
        return "Balloonport";
      case AirportType.closed:
        return "Closed";
    }
  }
}

class Airport {
  final String identCode;
  final AirportType type;
  final String name;
  final int? elevationFt;
  final String continent;
  final String isoCountry;
  final String isoRegion;
  final String municipality;
  final String iataCode;
  final LatLng location;

  Airport({
    required this.identCode,
    required this.type,
    required this.name,
    this.elevationFt,
    required this.continent,
    required this.isoCountry,
    required this.isoRegion,
    required this.municipality,
    required this.iataCode,
    required this.location,
  });

  static AirportType _parseAirportType(String type) {
    switch (type) {
      case "large_airport":
        return AirportType.largeAirport;
      case "medium_airport":
        return AirportType.mediumAirport;
      case "small_airport":
        return AirportType.smallAirport;
      case "seaplane_base":
        return AirportType.seaplaneBase;
      case "heliport":
        return AirportType.heliport;
      case "balloonport":
        return AirportType.balloonport;
      case "closed":
        return AirportType.closed;
      default:
        throw Exception("Unknown airport type: $type");
    }
  }

  factory Airport.fromCsv(List<String> csv) {
    final List<double> coords = csv[11].replaceAll(RegExp(("[^0-9,.-]")), "").split(",").map((el) => double.parse(el)).toList();
    return Airport(
      identCode: csv[0],
      type: _parseAirportType(csv[1]),
      name: csv[2],
      elevationFt: int.tryParse(csv[3]),
      continent: csv[4],
      isoCountry: csv[5],
      isoRegion: csv[6],
      municipality: csv[7],
      iataCode: csv[9],
      location: LatLng(coords[1], coords[0]),
    );
  }
}
