import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flutter/material.dart';

class StayWidget extends StatelessWidget {
  const StayWidget({super.key, required this.stay, this.isMini = false});

  final Stay stay;
  final bool isMini;

  @override
  Widget build(BuildContext context) {
    if (isMini) {
      return DeckWindow(
        hasWindowBar: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stay.name ?? ""),
              const SizedBox(height: 10),
              Text("${stay.start.day}/${stay.start.month}/${stay.start.year} -> ${stay.end.day}/${stay.end.month}/${stay.end.year}"),
              Text("${stay.stayLength} ${stay.stayLength == 1 ? "day" : "days"}"),
              const SizedBox(height: 10),
              Text("${stay.location.latitude}, ${stay.location.longitude}"),
              const SizedBox(height: 10),
              Text(stay.notes ?? ""),
            ],
          ),
        ),
      );
    }

    return DeckWindow(
      title: stay.name,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${stay.start.day}/${stay.start.month}/${stay.start.year} -> ${stay.end.day}/${stay.end.month}/${stay.end.year}"),
            Text("${stay.stayLength} ${stay.stayLength == 1 ? "day" : "days"}"),
            const SizedBox(height: 10),
            Text("${stay.location.latitude}, ${stay.location.longitude}"),
            const SizedBox(height: 10),
            Text(stay.notes ?? ""),
            const SizedBox(height: 10),
            const Text("Points of Interest"),
            MapWidget(locations: stay.places.map((e) => e.location).toList())
          ],
        ),
      ),
    );
  }
}
