import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flight_deck/models/airport.dart';
import 'package:latlong2/latlong.dart';

class AirportHandler {
  AirportHandler._();
  static final AirportHandler _instance = AirportHandler._();
  static AirportHandler get instance => _instance;

  static const String globalAirportFileName = 'assets/data_sets/airport_codes.csv';
  static const String auAirportFileName = 'assets/data_sets/au_apt.geojson';
  static const String auAirspaceFileName = 'assets/data_sets/au_asp.geojson';
  static const String auNavaidFileName = 'assets/data_sets/au_nav.geojson';
  static const String auObstacleFileName = 'assets/data_sets/au_obs.geojson';
  static const String auMergedFileName = 'assets/data_sets/au_merged.geojson';

  final List<Airport> _airports = [];
  List<Airport> get airports => _airports;

  final Map<String, dynamic> _auAirportGeoJson = {};
  Map<String, dynamic> get auAirportGeoJson => _auAirportGeoJson;

  final Map<String, dynamic> _auAirspaceGeoJson = {};
  Map<String, dynamic> get auAirspaceGeoJson => _auAirspaceGeoJson;

  final Map<String, dynamic> _auNavaidGeoJson = {};
  Map<String, dynamic> get auNavaidGeoJson => _auNavaidGeoJson;

  final Map<String, dynamic> _auObstacleGeoJson = {};
  Map<String, dynamic> get auObstacleGeoJson => _auObstacleGeoJson;

  final Map<String, dynamic> _auMergedGeoJson = {};
  Map<String, dynamic> get auMergedGeoJson => _auMergedGeoJson;

  Future<void> init() async {
    _auAirportGeoJson.addAll(jsonDecode(await rootBundle.loadString(auAirportFileName)));
    _auAirspaceGeoJson.addAll(jsonDecode(await rootBundle.loadString(auAirspaceFileName)));
    _auNavaidGeoJson.addAll(jsonDecode(await rootBundle.loadString(auNavaidFileName)));
    _auObstacleGeoJson.addAll(jsonDecode(await rootBundle.loadString(auObstacleFileName)));

    _auMergedGeoJson.addAll({
      "type": "FeatureCollection",
      "features": [
        ..._auAirportGeoJson['features'],
        ..._auAirspaceGeoJson['features'],
        ..._auNavaidGeoJson['features'],
        ..._auObstacleGeoJson['features']
      ]
    });

    final int totalLen = _auAirportGeoJson['features'].length +
        _auAirspaceGeoJson['features'].length +
        _auNavaidGeoJson['features'].length +
        _auObstacleGeoJson['features'].length;

    for (var i = 0; i < totalLen; i++) {
      _auMergedGeoJson['features'][i]['id'] = i + 1;

      if (_auMergedGeoJson['features'][i]['geometry']['type'] == "Point") {
        _auMergedGeoJson['features'][i]['geometry']['coordinates'][0] =
            (_auMergedGeoJson['features'][i]['geometry']['coordinates'][0].toDouble() + 0.0000001);
        _auMergedGeoJson['features'][i]['geometry']['coordinates'][1] =
            (_auMergedGeoJson['features'][i]['geometry']['coordinates'][1].toDouble() + 0.0000001);
      } else if (_auMergedGeoJson['features'][i]['geometry']['type'] == "LineString") {
        for (var j = 0; j < _auMergedGeoJson['features'][i]['geometry']['coordinates'].length; j++) {
          _auMergedGeoJson['features'][i]['geometry']['coordinates'][j][0] =
              (_auMergedGeoJson['features'][i]['geometry']['coordinates'][j][0].toDouble() + 0.0000001);
          _auMergedGeoJson['features'][i]['geometry']['coordinates'][j][1] =
              (_auMergedGeoJson['features'][i]['geometry']['coordinates'][j][1].toDouble() + 0.0000001);
        }
      } else if (_auMergedGeoJson['features'][i]['geometry']['type'] == "Polygon") {
        for (var j = 0; j < _auMergedGeoJson['features'][i]['geometry']['coordinates'][0].length; j++) {
          _auMergedGeoJson['features'][i]['geometry']['coordinates'][0][j][0] =
              (_auMergedGeoJson['features'][i]['geometry']['coordinates'][0][j][0].toDouble() + 0.0000001);
          _auMergedGeoJson['features'][i]['geometry']['coordinates'][0][j][1] =
              (_auMergedGeoJson['features'][i]['geometry']['coordinates'][0][j][1].toDouble() + 0.0000001);
        }
      }
    }

    final List<String> lines = (await rootBundle.loadString(globalAirportFileName)).split("\n");

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
