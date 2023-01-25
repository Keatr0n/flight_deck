import 'dart:math';

import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/stay_widget.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Stay> get stays => FlightDeckDB.instance.stays;

  double actualWidth() {
    double width = 0;

    DateTime currentMonth = DateTime(stays.first.start.year, stays.first.start.month);
    final int totalMonths = ((stays.last.end.year - stays.first.start.year) * 12) + ((stays.last.end.month + 1) - stays.first.start.month);

    for (var i = 0; i < totalMonths; i++) {
      final DateTime nextMonth = currentMonth.month == 12 ? DateTime(currentMonth.year + 1, 1) : DateTime(currentMonth.year, currentMonth.month + 1);
      width += 20 * nextMonth.difference(currentMonth).inDays;
      currentMonth = nextMonth;
    }

    return width;
  }

  List<Widget> buildStay(List<Stay> stays) {
    final List<Widget> miniStayWidgets = [];

    final originOffset = DateTime(stays.first.start.year, stays.first.start.month, 1);

    for (var i = 0; i < stays.length; i++) {
      miniStayWidgets.add(Positioned(
        left: stays[i].start.difference(originOffset).inDays * 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StayWidget(stay: stays[i], isMini: true),
            Center(
              child: Container(
                transformAlignment: Alignment.center,
                color: Theme.of(context).primaryColor,
                height: i % 2 == 0 ? 30 : 150,
                width: 2,
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              width: stays[i].stayLength * 20,
              height: 2,
            ),
            SizedBox(height: i % 2 == 0 ? 4 : 1),
          ],
        ),
      ));
    }

    return miniStayWidgets;
  }

  List<Widget> calendar() {
    final int totalMonths = ((stays.last.end.year - stays.first.start.year) * 12) + ((stays.last.end.month + 1) - stays.first.start.month);
    final List<Widget> timeline = [];

    DateTime currentMonth = DateTime(stays.first.start.year, stays.first.start.month);

    for (var i = 0; i < totalMonths; i++) {
      final DateTime nextMonth = currentMonth.month == 12 ? DateTime(currentMonth.year + 1, 1) : DateTime(currentMonth.year, currentMonth.month + 1);

      timeline.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var l = 0; l < currentMonth.difference(nextMonth).inDays.abs(); l++) ...[
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: 1 + (l == 0 ? 2 : 0),
                    height: 8,
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: 18 - (l == 0 ? 2 : 0),
                    height: 2,
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                    height: 8,
                  ),
                ]
              ],
            ),
            Container(
              color: Theme.of(context).primaryColor,
              width: 2,
              height: 30,
            ),
            Text("${currentMonth.month}/${currentMonth.year}"),
          ],
        ),
      );

      currentMonth = nextMonth;
    }

    return timeline;
  }

  @override
  Widget build(BuildContext context) {
    if (stays.isEmpty) return const Center(child: Text("ERROR 404: No stays found"));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 500,
              width: actualWidth(),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: buildStay(stays),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: calendar(),
            ),
          ],
        ),
      ),
    );
  }
}
