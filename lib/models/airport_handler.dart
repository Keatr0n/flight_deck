import 'package:flutter/services.dart' show rootBundle;

import 'package:flight_deck/models/airport.dart';
import 'package:latlong2/latlong.dart';

class AirportHandler {
  AirportHandler._();
  static final AirportHandler _instance = AirportHandler._();
  static AirportHandler get instance => _instance;

  static const String fileName = 'assets/data_sets/airport_codes.csv';

  final List<Airport> _airports = [];
  List<Airport> get airports => _airports;

  Future<void> init() async {
    final List<String> lines = (await rootBundle.loadString(fileName)).split("\n");

    lines.last.isEmpty ? lines.removeLast() : null;

    for (var i = 1; i < lines.length; i++) {
      final List<String> csvLine = [];
      bool inQuotes = false;
      int lastComma = 0;

      for (var l = 0; l < lines[i].length; l++) {
        if (lines[i][l] == '"') {
          inQuotes = !inQuotes;
        }

        if (lines[i][l] == ',' && !inQuotes) {
          csvLine.add(lines[i].substring(lastComma, l));
          lastComma = l + 1;
          continue;
        }

        if (l == lines[i].length - 1) {
          csvLine.add(lines[i].substring(lastComma, l));
        }
      }

      inQuotes = false;

      _airports.add(Airport.fromCsv(csvLine));
    }
  }

  List<Airport> search(String query) {
    final found = _airports.where((airport) {
      return airport.identCode.toLowerCase().contains(query.toLowerCase()) ||
          airport.name.toLowerCase().contains(query.toLowerCase()) ||
          airport.municipality.toLowerCase().contains(query.toLowerCase()) ||
          airport.iataCode.toLowerCase().contains(query.toLowerCase());
    }).toList();

    found.sort((a, b) {
      if (a.iataCode.toLowerCase().startsWith(query.toLowerCase())) {
        return -1;
      } else if (b.iataCode.toLowerCase().startsWith(query.toLowerCase())) {
        return 1;
      } else if (a.name.toLowerCase().startsWith(query.toLowerCase())) {
        return -1;
      } else if (b.name.toLowerCase().startsWith(query.toLowerCase())) {
        return 1;
      } else {
        return a.identCode.compareTo(b.identCode);
      }
    });

    return found;
  }

  Airport? getAirportByIata(String iata) {
    try {
      return _airports.firstWhere((airport) => airport.iataCode == iata);
    } catch (e) {
      return null;
    }
  }

  Airport? getAirportByIdent(String ident) {
    try {
      return _airports.firstWhere((airport) => airport.identCode == ident);
    } catch (e) {
      return null;
    }
  }

  Airport? getAirportByLocation(LatLng location) {
    try {
      return _airports.firstWhere((airport) {
        return airport.location.latitude == location.latitude && airport.location.longitude == location.longitude;
      });
    } catch (e) {
      return null;
    }
  }
}
