import 'package:flight_deck/models/airport.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flutter/material.dart';

class AirportDisplay extends StatelessWidget {
  const AirportDisplay(this.airport, {super.key});

  final Airport airport;

  @override
  Widget build(BuildContext context) {
    return DeckWindow(
      onClose: () => Navigator.of(context).pop(),
      tabs: [
        DeckWindowTab(
          title: airport.name,
          child: Container(
            width: 280,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(airport.name),
                const SizedBox(height: 10),
                Text("Type: ${airport.type.name}"),
                const SizedBox(height: 5),
                Text("IATA: ${airport.iataCode}"),
                const SizedBox(height: 5),
                Text("IDENT: ${airport.identCode}"),
                const SizedBox(height: 5),
                Text("${airport.municipality}, ${airport.isoRegion}, ${airport.isoCountry}"),
                const SizedBox(height: 10),
                Text("Location: ${airport.location.latitude.toStringAsFixed(3)}, ${airport.location.longitude.toStringAsFixed(3)}"),
                const SizedBox(height: 5),
                Text("Elevation: ${airport.elevationFt}"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
