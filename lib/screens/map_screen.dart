import 'dart:async';

import 'package:flight_deck/models/airport.dart';
import 'package:flight_deck/models/airport_handler.dart';
import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/airport_display.dart';
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
  List<Airport> get airports => AirportHandler.instance.airports;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: DeckWindow(
          backgroundOpacity: 0.1,
          tabs: [
            if (stays.isNotEmpty)
              DeckWindowTab(
                title: "STAYS",
                child: MapWidget(
                  key: const Key("stays"),
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
                  height: MediaQuery.of(context).size.height - 140,
                  width: MediaQuery.of(context).size.width,
                  locations: [for (var stay in stays) MapLocation.pointOnMap(stay.location)],
                ),
              ),
            DeckWindowTab(
              title: "AIRPORTS",
              child: MapWidget(
                key: const Key("airports"),
                onTap: (index, location) {
                  if (index == null) return;
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        child: AirportDisplay(airports[index]),
                      ),
                    ),
                  );
                },
                height: MediaQuery.of(context).size.height - 140,
                width: MediaQuery.of(context).size.width,
                locations: [for (var airport in airports) MapLocation.pointOnMap(airport.location)],
              ),
            ),
            DeckWindowTab(
              title: "AIRSPACE",
              child: MapWidget(
                key: const Key("airports"),
                onTap: (index, location) {
                  if (index == null) return;
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        child: AirportDisplay(airports[index]),
                      ),
                    ),
                  );
                },
                height: MediaQuery.of(context).size.height - 140,
                width: MediaQuery.of(context).size.width,
                geoJson: AirportHandler.instance.auMergedGeoJson,
              ),
            )
          ],
        ),
      ),
    );
  }
}
