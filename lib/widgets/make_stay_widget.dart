import 'package:flight_deck/models/airport.dart';
import 'package:flight_deck/models/airport_handler.dart';
import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class MakeStayWidget extends StatefulWidget {
  const MakeStayWidget({super.key, this.existingStayIndex, this.existingStay, this.exitOnSave = false});

  final int? existingStayIndex;
  final Stay? existingStay;
  final bool exitOnSave;

  @override
  State<MakeStayWidget> createState() => _MakeStayWidgetState();
}

class _MakeStayWidgetState extends State<MakeStayWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController locationSearchController = TextEditingController();
  final MapController mapController = MapController();

  List<Airport> searchResults = [];

  DateTime start = DateTime.now();
  DateTime end = DateTime.now().add(const Duration(days: 1));

  LatLng location = const LatLng(0, 0);

  int getDaysInMonth(DateTime date) {
    if (date.month == 12) return 31;

    return DateTime(date.year, date.month, 1).difference(DateTime(date.year, date.month + 1, 1)).inDays.abs();
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    durationController.dispose();
    locationSearchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.existingStay != null) {
      nameController.text = widget.existingStay!.name ?? "";
      notesController.text = widget.existingStay!.notes ?? "";
      durationController.text = widget.existingStay!.stayLength.toString();
      locationSearchController.text = AirportHandler.instance.getAirportByLocation(widget.existingStay!.location)?.name ?? "";
      start = widget.existingStay!.start;
      end = widget.existingStay!.end;
      location = widget.existingStay!.location;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 140,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFFE90808)),
                decoration: const InputDecoration(
                  label: Text("NAME"),
                  labelStyle: TextStyle(color: Color(0xFFE90808)),
                  fillColor: Colors.black26,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 5,
                style: const TextStyle(color: Color(0xFFE90808)),
                decoration: const InputDecoration(
                  label: Text("NOTES"),
                  labelStyle: TextStyle(color: Color(0xFFE90808)),
                  fillColor: Colors.black26,
                  filled: true,
                ),
              ),
              const SizedBox(height: 10),
              const Text("START DATE"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    items: List.generate(getDaysInMonth(start), (index) => DropdownMenuItem<int>(value: index + 1, child: Text((index + 1).toString()))),
                    onChanged: (value) => setState(() {
                      start = DateTime(start.year, start.month, value!);
                      durationController.text = (end.difference(start).inDays).toString();
                    }),
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: start.day,
                  ),
                  DropdownButton<int>(
                    items: List.generate(12, (index) => DropdownMenuItem<int>(value: index + 1, child: Text("${DateFormat.LLL().format(DateTime(start.year, index + 1, 1))} (${index + 1})"))),
                    onChanged: (value) {
                      if (getDaysInMonth(DateTime(start.year, value!, 1)) < start.day) {
                        setState(() {
                          start = DateTime(start.year, value, getDaysInMonth(DateTime(start.year, value, 1)));
                          durationController.text = (end.difference(start).inDays).toString();
                        });
                      } else {
                        setState(() {
                          start = DateTime(start.year, value, start.day);
                          durationController.text = (end.difference(start).inDays).toString();
                        });
                      }
                    },
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: start.month,
                  ),
                  DropdownButton<int>(
                    items: List.generate(10, (index) => DropdownMenuItem<int>(value: index + DateTime.now().year, child: Text((index + DateTime.now().year).toString()))),
                    onChanged: (value) => setState(() {
                      start = DateTime(value!, start.month, start.day);
                      durationController.text = (end.difference(start).inDays).toString();
                    }),
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: start.year,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("END DATE"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    items: List.generate(getDaysInMonth(end), (index) => DropdownMenuItem<int>(value: index + 1, child: Text((index + 1).toString()))),
                    onChanged: (value) => setState(() {
                      end = DateTime(end.year, end.month, value!);
                      durationController.text = (end.difference(start).inDays).toString();
                    }),
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: end.day,
                  ),
                  DropdownButton<int>(
                    items: List.generate(12, (index) => DropdownMenuItem<int>(value: index + 1, child: Text("${DateFormat.LLL().format(DateTime(end.year, index + 1, 1))} (${index + 1})"))),
                    onChanged: (value) {
                      if (getDaysInMonth(DateTime(end.year, value!, 1)) < end.day) {
                        setState(() {
                          end = DateTime(end.year, value, getDaysInMonth(DateTime(end.year, value, 1)));
                          durationController.text = (end.difference(start).inDays).toString();
                        });
                      } else {
                        setState(() {
                          end = DateTime(end.year, value, end.day);
                          durationController.text = (end.difference(start).inDays).toString();
                        });
                      }
                    },
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: end.month,
                  ),
                  DropdownButton<int>(
                    items: List.generate(10, (index) => DropdownMenuItem<int>(value: index + DateTime.now().year, child: Text((index + DateTime.now().year).toString()))),
                    onChanged: (value) => setState(() {
                      end = DateTime(value!, end.month, end.day);
                      durationController.text = (end.difference(start).inDays).toString();
                    }),
                    style: const TextStyle(color: Color(0xFFE90808)),
                    value: end.year,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("-OR-"),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Color(0xFFE90808)),
                  decoration: const InputDecoration(
                    label: Text("STAY DURATION (NIGHTS)"),
                    labelStyle: TextStyle(color: Color(0xFFE90808)),
                    fillColor: Colors.black26,
                    filled: true,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && start.add(Duration(days: int.tryParse(value) ?? 1)).isBefore(DateTime(DateTime.now().year + 10, 1, 1)) && start.add(Duration(days: int.tryParse(value) ?? 1)).isAfter(DateTime(DateTime.now().year, 1, 1))) {
                      setState(() {
                        end = start.add(Duration(days: int.tryParse(value) ?? 1));
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    TextField(
                      controller: locationSearchController,
                      style: const TextStyle(color: Color(0xFFE90808)),
                      decoration: const InputDecoration(
                        label: Text("SEARCH LOCATION"),
                        labelStyle: TextStyle(color: Color(0xFFE90808)),
                        fillColor: Colors.black26,
                        filled: true,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          searchResults = AirportHandler.instance.search(value);
                          if (searchResults.isNotEmpty && searchResults.length == 1) {
                            location = searchResults.first.location;
                            locationSearchController.text = searchResults.first.name;
                            mapController.move(searchResults.first.location, 8);
                          }

                          if (searchResults.isNotEmpty && searchResults.length > 4) {
                            searchResults = searchResults.getRange(0, 4).toList();
                          }
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (searchResults.isNotEmpty)
                      for (var result in searchResults)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: DeckButton(
                            onTap: () {
                              location = result.location;
                              locationSearchController.text = result.name;
                              mapController.move(result.location, 8);

                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width,
                              child: Text("${result.name} (${result.iataCode.isEmpty ? result.identCode : result.iataCode})"),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              MapWidget(
                width: MediaQuery.of(context).size.width,
                locations: [MapLocation(location: location)],
                mapController: mapController,
                onTap: (_, location) {
                  this.location = location;
                  setState(() {});
                },
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  if (widget.existingStay != null && widget.existingStayIndex != null) {
                    FlightDeckDB.instance.updateStay(
                      widget.existingStayIndex!,
                      Stay(
                        name: nameController.text,
                        start: start,
                        end: end,
                        location: location,
                        places: widget.existingStay!.places,
                        notes: notesController.text,
                        isFixedDate: false,
                      ),
                    );
                  } else {
                    FlightDeckDB.instance.addStay(Stay(
                      name: nameController.text,
                      start: start,
                      end: end,
                      location: location,
                      places: [],
                      notes: notesController.text,
                      isFixedDate: false,
                    ));
                  }

                  if (widget.exitOnSave) Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: const Color(0xFFE90808), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      "SAVE",
                      style: TextStyle(color: Color(0xFFE90808)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
