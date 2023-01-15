import 'package:flight_deck/models/stay.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'map_widget.dart';

class StayWidget extends StatelessWidget {
  const StayWidget({super.key, required this.stay, this.hasMap = true});

  final Stay stay;
  final bool hasMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(stay.name ?? ""),
        Text("${stay.start.day}/${stay.start.month}/${stay.start.year} -> ${stay.end.day}/${stay.end.month}/${stay.end.year} (${stay.stayLength} days)"),
        Text("${stay.location.latitude}, ${stay.location.longitude}"),
        Text(stay.notes ?? ""),
        MapWidget(locations: [LatLng(51.5287718, -0.2416805), LatLng(38.003520, 23.772970)]),
      ],
    );
  }
}
