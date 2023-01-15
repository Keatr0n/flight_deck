import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/stay_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return StayWidget(
      stay: Stay(
        end: DateTime.now().add(const Duration(days: 5)),
        start: DateTime.now(),
        places: [],
        location: LatLng(51.5287718, -0.2416805),
      ),
    );
  }
}
