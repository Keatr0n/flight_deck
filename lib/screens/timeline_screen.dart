import 'dart:async';

import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/make_stay_widget.dart';
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

  List<Widget> buildStays() {
    final List<Widget> miniStayWidgets = List.filled(stays.length, const SizedBox());
    final List<int> yLevels = List.filled(stays.length, 0);

    // precalculate y levels so we don't have super ugly overlaps
    for (var i = 0; i < yLevels.length; i++) {
      if (i == 0) continue;

      if (stays[i].start.isBefore(stays[i - 1].start.add(Duration(days: stays[i - 1].stayLength > 14 ? stays[i - 1].stayLength : 14)))) {
        final firstStayInChain = stays[(i - (yLevels[i - 1] + 1))];

        if (stays[i].start.isBefore(firstStayInChain.start.add(Duration(days: firstStayInChain.stayLength > 14 ? firstStayInChain.stayLength : 14)))) {
          yLevels[i] = yLevels[i - 1] + 1;
        }
      }
    }

    final originOffset = DateTime(stays.first.start.year, stays.first.start.month, 1);

    for (var i = stays.length - 1; i >= 0; i--) {
      miniStayWidgets[(stays.length - i) - 1] = Positioned(
        left: stays[i].start.difference(originOffset).inDays * 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => Material(
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: StayWidget(
                      stay: stays[i],
                      onClose: () => Navigator.of(context).pop(),
                      onEdit: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => Material(
                            color: Colors.black38,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                              child: MakeStayWidget(
                                existingStay: stays[i],
                                existingStayIndex: i,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              child: StayWidget(stay: stays[i], isMini: true),
            ),
            Center(
              child: Container(
                transformAlignment: Alignment.center,
                color: yLevels[i] != 0 ? Theme.of(context).primaryColor.withOpacity(0.4) : Theme.of(context).primaryColor,
                height: (yLevels[i] * 120) + 30,
                width: 2,
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              width: stays[i].stayLength * 20,
              height: 2,
            ),
            SizedBox(height: yLevels[i] * 3),
          ],
        ),
      );
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: actualWidth(),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: buildStays(),
                ),
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
