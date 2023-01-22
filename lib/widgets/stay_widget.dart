import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flutter/material.dart';

class StayWidget extends StatefulWidget {
  const StayWidget({super.key, required this.stay, this.isMini = false});

  final Stay stay;
  final bool isMini;

  @override
  State<StayWidget> createState() => _StayWidgetState();
}

class _StayWidgetState extends State<StayWidget> {
  int? highlightIndex;

  List<Widget> placeTabs() {
    final List<Widget> tabs = [];

    for (var i = 0; i < widget.stay.places.length; i++) {
      tabs.add(GestureDetector(
        onTap: () => setState(() => highlightIndex = i),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA60707), width: i == highlightIndex ? 4 : 2),
          ),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Text(widget.stay.places[i].name),
              Text("${widget.stay.places[i].location.latitude}, ${widget.stay.places[i].location.longitude}"),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMini) {
      return DeckWindow(
        hasWindowBar: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.stay.name ?? ""),
              const SizedBox(height: 10),
              Text("${widget.stay.start.day}/${widget.stay.start.month}/${widget.stay.start.year} -> ${widget.stay.end.day}/${widget.stay.end.month}/${widget.stay.end.year}"),
              Text("${widget.stay.stayLength} ${widget.stay.stayLength == 1 ? "day" : "days"}"),
              const SizedBox(height: 10),
              Text("${widget.stay.location.latitude}, ${widget.stay.location.longitude}"),
            ],
          ),
        ),
      );
    }

    return DeckWindow(
      title: widget.stay.name,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${widget.stay.start.day}/${widget.stay.start.month}/${widget.stay.start.year} -> ${widget.stay.end.day}/${widget.stay.end.month}/${widget.stay.end.year} (${widget.stay.stayLength} ${widget.stay.stayLength == 1 ? "day" : "days"})"),
            const SizedBox(height: 10),
            Text(widget.stay.notes ?? ""),
            // const SizedBox(height: 10),
            // Text("${stay.location.latitude}, ${stay.location.longitude}"),
            const SizedBox(height: 10),
            const Text("Points of Interest"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: placeTabs()),
                const SizedBox(width: 10),
                MapWidget(
                  locations: widget.stay.places.map((e) => e.location).toList(),
                  highlightedIndex: highlightIndex,
                  onTap: (index) {
                    if (index != null && index != highlightIndex && mounted) {
                      setState(() {
                        highlightIndex = index;
                      });
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
