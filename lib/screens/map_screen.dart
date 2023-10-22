import 'dart:async';

import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flight_deck/widgets/stay_widget.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Stay> get stays => FlightDeckDB.instance.stays;

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
      child: SafeArea(
        child: DeckWindow(
          hasWindowBar: false,
          backgroundOpacity: 0.1,
          child: MapWidget(
            onTap: (index, location) {
              if (index == null) return;

              showDialog(
                context: context,
                builder: (context) => Material(
                  color: Colors.black38,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                      child: StayWidget(stay: stays[index], onClose: () => Navigator.of(context).pop())),
                ),
              );
            },
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            locations: [for (var stay in stays) MapLocation.pointOnMap(stay.location)],
          ),
        ),
      ),
    );
  }
}
