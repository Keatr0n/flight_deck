import 'dart:async';
import 'dart:convert';

import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/utils/file_utils.dart';

class FlightDeckDB {
  FlightDeckDB._();
  static final FlightDeckDB _instance = FlightDeckDB._();
  static FlightDeckDB get instance => _instance;

  static const String fileName = 'flightDeckDB.json';

  final bool _initialized = false;

  List<Stay> _stays = [];
  List<Stay> get stays => _stays;

  Completer<void> _saveCompleter = Completer<void>();

  Future<void> init() async {
    if (_initialized) return;

    final jsonString = await FileUtils.readLocalFile(fileName);

    if (jsonString.startsWith("ERROR:")) {
      throw Exception(jsonString);
    }

    final jsonData = jsonDecode(jsonString);

    _stays = (jsonData['stays'] as List).map<Stay>((e) => Stay.fromJson(e)).toList();

    return;
  }

  Future<void> save() async {
    if (!_saveCompleter.isCompleted) await _saveCompleter.future;
    _saveCompleter = Completer<void>();

    final jsonString = jsonEncode({
      'stays': _stays.map((e) => e.toJson()).toList(),
    });

    await FileUtils.writeLocalFile(fileName, jsonString);

    _saveCompleter.complete();
    return;
  }

  void addStay(Stay stay) {
    _stays.add(stay);
    save();
  }

  void deleteStay(Stay stay) {
    _stays.remove(stay);
    save();
  }

  void updateStay(int index, Stay stay) {
    _stays[index] = stay;
    save();
  }
}
