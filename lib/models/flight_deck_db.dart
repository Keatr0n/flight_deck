import 'dart:async';
import 'dart:convert';

import 'package:flight_deck/models/app_state_memory.dart';
import 'package:flight_deck/models/checklist.dart';
import 'package:flight_deck/models/job_scheduler.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/models/user_settings.dart';
import 'package:flight_deck/utils/file_utils.dart';
import 'package:flutter/services.dart';

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

  UserSettings _userSettings = UserSettings.empty();
  UserSettings get userSettings => _userSettings;

  AppStateMemory _appStateMemory = AppStateMemory.empty();
  AppStateMemory get appStateMemory => _appStateMemory;

  List<Checklist> _checklists = [];
  List<Checklist> get checklists => _checklists;

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
    _stays = List.from(jsonData['stays']).map<Stay>((e) => Stay.fromJson(e)).toList();
    _userSettings = UserSettings.fromJson(jsonData['userSettings'] ?? {});
    _appStateMemory = AppStateMemory.fromJson(jsonData['appStateMemory'] ?? {});
    _checklists = List.from(jsonData['checklists']).map<Checklist>((e) => Checklist.fromJson(e)).toList();
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

  /// DON'T DO THIS EVER!!!
  void wipeDB() {
    _stays = [];
    _userSettings = UserSettings.empty();
    _appStateMemory = AppStateMemory.empty();
    _checklists = [];
    _jobScheduler.addJob(save);
  }

  void export() {
    final jsonString = jsonEncode({
      'stays': _stays.map((e) => e.toJson()).toList(),
      'userSettings': _userSettings.toJson(),
      'appStateMemory': _appStateMemory.toJson(),
      'checklists': _checklists.map((e) => e.toJson()).toList(),
    });

    Clipboard.setData(ClipboardData(text: jsonString));
  }

  /// Returns null if import was successful. Otherwise, returns the error message.
  Future<String?> import() async {
    final jsonString = (await Clipboard.getData("text/plain"))?.text ?? "";

    if (jsonString.isEmpty) return "Clipboard is empty";

    try {
      final jsonData = jsonDecode(jsonString);

      _stays = List.from(jsonData['stays']).map<Stay>((e) => Stay.fromJson(e)).toList();
      _userSettings = UserSettings.fromJson(jsonData['userSettings'] ?? {});
      _appStateMemory = AppStateMemory.fromJson(jsonData['appStateMemory'] ?? {});
      _checklists = List.from(jsonData['checklists']).map<Checklist>((e) => Checklist.fromJson(e)).toList();
      _initialized = true;

      save();
    } catch (e) {
      if (e is FormatException) {
        return "Clipboard is not valid JSON\n\n$jsonString";
      }
      return e.toString();
    }

    return null;
  }

  Future<void> save() async {
    _updateDbStreamController.add(null);

    final jsonString = jsonEncode({
      'stays': _stays.map((e) => e.toJson()).toList(),
      'userSettings': _userSettings.toJson(),
      'appStateMemory': _appStateMemory.toJson(),
      'checklists': _checklists.map((e) => e.toJson()).toList(),
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

  void updateAppStateMemory(AppStateMemory appStateMemory) {
    _appStateMemory = appStateMemory;
    _jobScheduler.addJob(save);
  }

  void addChecklist(Checklist checklist) {
    _checklists.add(checklist);
    _jobScheduler.addJob(save);
  }

  void deleteChecklist(Checklist checklist) {
    _checklists.remove(checklist);
    _jobScheduler.addJob(save);
  }

  void updateChecklist(int index, Checklist checklist) {
    _checklists[index] = checklist;
    _jobScheduler.addJob(save);
  }
}
