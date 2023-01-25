import 'dart:async';

import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/make_place_widget.dart';
import 'package:flight_deck/widgets/make_stay_widget.dart';
import 'package:flight_deck/widgets/stay_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaysScreen extends StatefulWidget {
  const StaysScreen({super.key});

  @override
  State<StaysScreen> createState() => _StaysScreenState();
}

class _StaysScreenState extends State<StaysScreen> {
  List<Stay> get stays => FlightDeckDB.instance.stays;

  int selectedStay = 0;

  late final StreamSubscription updateDbStream;

  @override
  void dispose() {
    updateDbStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    updateDbStream = FlightDeckDB.instance.updateDbStream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const Center(child: Text("ERROR 404: No stays found"));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DeckWindow(
        hasWindowBar: false,
        backgroundOpacity: 0.1,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < stays.length; i++)
                    GestureDetector(
                      onTap: () {
                        selectedStay = i;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: const Color(0xFFA60707), width: selectedStay == i ? 3 : 1),
                            horizontal: BorderSide(color: const Color(0xFFA60707), width: selectedStay == i ? 5 : 3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(stays[i].name ?? "", style: TextStyle(fontWeight: selectedStay == i ? FontWeight.bold : FontWeight.normal)),
                            Text(
                              "${DateFormat.MMMd().format(stays[i].start).toString()} (${stays[i].stayLength} days)",
                              style: TextStyle(fontWeight: selectedStay == i ? FontWeight.bold : FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
            Expanded(
              child: StayWidget(
                stay: stays[selectedStay],
                isMini: false,
                usesDeckWindow: false,
                onDelete: () {
                  final int indexToDelete = selectedStay;

                  if (selectedStay >= stays.length - 1) {
                    selectedStay = selectedStay - 1;
                    if (selectedStay < 0) selectedStay = 0;
                  }

                  FlightDeckDB.instance.deleteStay(stays[indexToDelete]);
                },
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        child: MakeStayWidget(
                          existingStay: stays[selectedStay],
                          existingStayIndex: selectedStay,
                        ),
                      ),
                    ),
                  );
                },
                onDeletePlace: (p0) {
                  FlightDeckDB.instance.updateStay(
                    selectedStay,
                    stays[selectedStay].copyWith(places: stays[selectedStay].places.where((element) => element != p0).toList()),
                  );
                },
                onNewPlace: () {
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        child: MakePlaceWidget(
                          onDone: (newPlace) {
                            FlightDeckDB.instance.updateStay(
                              selectedStay,
                              stays[selectedStay].copyWith(places: [...stays[selectedStay].places, newPlace]),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
