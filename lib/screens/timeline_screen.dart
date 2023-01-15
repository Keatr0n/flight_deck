import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/stay_widget.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final controllerMini = ScrollController();
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final stays = [
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
      Stay.random(),
    ];

    final itemHeight = MediaQuery.of(context).size.height * 0.8;
    final itemWidth = MediaQuery.of(context).size.width * 0.8;

    return Column(
      children: [
        SizedBox(
          height: itemHeight / 8,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (controllerMini.offset - details.delta.dx < 0 || controllerMini.offset - details.delta.dx > controllerMini.position.maxScrollExtent) return;
              controllerMini.jumpTo(controllerMini.offset - details.delta.dx);
              controller.jumpTo(controller.offset - (details.delta.dx * 4));
            },
            child: ListView(
              controller: controllerMini,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: itemWidth / 2),
                ...stays.map((e) => SizedBox(height: itemHeight / 4, width: itemWidth / 4, child: FittedBox(fit: BoxFit.scaleDown, child: StayWidget(stay: e, isMini: true)))).toList(),
                SizedBox(width: itemWidth / 2),
              ], //FlightDeckDB.instance.stays.map((stay) => StayWidget(stay: stay)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: itemHeight,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (controllerMini.offset - details.delta.dx < 0 || controllerMini.offset - details.delta.dx > controllerMini.position.maxScrollExtent) return;
              controllerMini.jumpTo(controllerMini.offset - (details.delta.dx / 4));
              controller.jumpTo(controller.offset - details.delta.dx);
            },
            child: ListView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: itemWidth / 8),
                ...stays.map((e) => SizedBox(height: itemHeight, width: itemWidth, child: StayWidget(stay: e))).toList(),
                SizedBox(width: itemWidth / 8)
              ], //FlightDeckDB.instance.stays.map((stay) => StayWidget(stay: stay)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
