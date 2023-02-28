import 'dart:async';
import 'dart:convert';

import 'package:flight_deck/models/job_scheduler.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/utils/file_utils.dart';

class FlightDeckDB {
  FlightDeckDB._();
  static final FlightDeckDB _instance = FlightDeckDB._();
  static FlightDeckDB get instance => _instance;

  static const String fileName = 'flightDeckDB.json';

  final StreamController _updateDbStreamController = StreamController.broadcast();
  Stream get updateDbStream => _updateDbStreamController.stream;

  bool _initialized = false;

  List<Stay> _stays = [];
  List<Stay> get stays => _stays;

  final JobScheduler _jobScheduler = JobScheduler();

  Future<void> init() async {
    if (_initialized) return;

    final jsonString = await FileUtils.readLocalFile(fileName);

    if (jsonString.startsWith("ERROR:")) {
      throw Exception(jsonString);
    }

    if (jsonString.isEmpty) {
      _initialized = true;
      return;
    }

    final jsonData = jsonDecode(jsonString);
    _stays = (jsonData['stays'] as List).map<Stay>((e) => Stay.fromJson(e)).toList();
    _initialized = true;

    return;
  }

  int getFirstStayIndexEndingAfterNow() {
    final now = DateTime.now();
    for (var i = 0; i < _stays.length; i++) {
      if (stays[i].end.isAfter(now)) {
        return i;
      }
    }
    return 0;
  }

  Future<void> save() async {
    _updateDbStreamController.add(null);

    final jsonString = jsonEncode({
      'stays': _stays.map((e) => e.toJson()).toList(),
    });

    await FileUtils.writeLocalFile(fileName, jsonString);

    return;
  }

  void addStay(Stay stay) {
    _stays.add(stay);
    _stays.sort((a, b) => a.start.compareTo(b.start));
    _jobScheduler.addJob(save);
  }

  void deleteStay(Stay stay) {
    _stays.remove(stay);
    _stays.sort((a, b) => a.start.compareTo(b.start));
    _jobScheduler.addJob(save);
  }

  void updateStay(int index, Stay stay) {
    _stays[index] = stay;
    _stays.sort((a, b) => a.start.compareTo(b.start));
    _jobScheduler.addJob(save);
  }
}
