import 'package:flight_deck/models/place.dart';
import 'package:flight_deck/models/stay.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flutter/material.dart';

class StayWidget extends StatefulWidget {
  const StayWidget({
    super.key,
    required this.stay,
    this.isMini = false,
    this.usesDeckWindow = true,
    this.onEdit,
    this.onNewPlace,
    this.onDeletePlace,
    this.onDelete,
  });

  final Stay stay;
  final bool isMini;
  final bool usesDeckWindow;
  final void Function()? onEdit;
  final void Function()? onNewPlace;
  final void Function(Place)? onDeletePlace;
  final void Function()? onDelete;

  @override
  State<StayWidget> createState() => _StayWidgetState();
}

class _StayWidgetState extends State<StayWidget> {
  int? highlightIndex;

  List<Widget> placeTabs() {
    final List<Widget> tabs = [];

    for (var i = 0; i < widget.stay.places.length; i++) {
      tabs.add(DeckButton(
        onTap: () => setState(() => highlightIndex = i),
        borderWidth: i == highlightIndex ? 3 : 1,
        width: 100,
        child: Text(
          widget.stay.places[i].name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: highlightIndex == i ? FontWeight.bold : FontWeight.normal),
        ),
      ));
    }

    if (widget.onNewPlace != null) {
      tabs.add(
        DeckButton(
          onTap: widget.onNewPlace,
          borderWidth: highlightIndex == widget.stay.places.length ? 3 : 1,
          width: 100,
          child: const Icon(Icons.add_sharp, color: Color(0xFFA60707)),
        ),
      );
    }

    if (tabs.isEmpty) tabs.add(const SizedBox(width: 100, child: Text("No places found")));

    return tabs;
  }

  Widget deckWindowWrapper(Widget child) {
    if (widget.usesDeckWindow) {
      return DeckWindow(
        hasWindowBar: !widget.isMini,
        title: widget.stay.name,
        child: child,
      );
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMini) {
      return deckWindowWrapper(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.stay.name ?? ""),
              const SizedBox(height: 10),
              Text("${widget.stay.start.day}/${widget.stay.start.month}/${widget.stay.start.year} -> ${widget.stay.end.day}/${widget.stay.end.month}/${widget.stay.end.year}"),
              Text("${widget.stay.stayLength} ${widget.stay.stayLength == 1 ? "day" : "days"}"),
              const SizedBox(height: 10),
              Text("${widget.stay.location.latitude.toStringAsFixed(3)}, ${widget.stay.location.longitude.toStringAsFixed(3)}"),
            ],
          ),
        ),
      );
    }

    return deckWindowWrapper(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.usesDeckWindow ? "" : widget.stay.name ?? ""),
            const SizedBox(height: 10),
            Text("${widget.stay.start.day}/${widget.stay.start.month}/${widget.stay.start.year} -> ${widget.stay.end.day}/${widget.stay.end.month}/${widget.stay.end.year} (${widget.stay.stayLength} ${widget.stay.stayLength == 1 ? "day" : "days"})"),
            const SizedBox(height: 10),
            Text(widget.stay.notes ?? ""),
            // const SizedBox(height: 10),
            // Text("${stay.location.latitude}, ${stay.location.longitude}"),
            const SizedBox(height: 15),
            const Text("Points of Interest"),
            const SizedBox(height: 6),
            Container(
              height: (MediaQuery.of(context).size.height * 0.4) + 85,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA60707), width: 2),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        DeckButton(
                          onTap: () {
                            if ((highlightIndex ?? 0) >= widget.stay.places.length - 1) {
                              highlightIndex = (highlightIndex ?? 1) - 1;
                              widget.onDeletePlace?.call(widget.stay.places[(highlightIndex ?? 0) + 1]);
                            } else {
                              widget.onDeletePlace?.call(widget.stay.places[highlightIndex ?? 0]);
                            }

                            if ((highlightIndex ?? 0) < 0) highlightIndex = 0;
                          },
                          height: 80,
                          width: 50,
                          child: const Icon(Icons.delete_sharp, color: Color(0xFFA60707)),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: widget.stay.places.isNotEmpty
                                  ? [
                                      Text(widget.stay.places[highlightIndex ?? 0].address ?? ""),
                                      const SizedBox(height: 4),
                                      Text(widget.stay.places[highlightIndex ?? 0].notes ?? ""),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(child: Column(children: placeTabs())),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Color(0xFFA60707), width: 1), top: BorderSide(color: Color(0xFFA60707), width: 1)),
                        ),
                        child: MapWidget(
                          locations: widget.stay.places.map((e) => e.location).toList(),
                          highlightedIndex: highlightIndex,
                          centre: widget.stay.location,
                          width: MediaQuery.of(context).size.width - 141,
                          onTap: (index, location) {
                            if (index != null && index != highlightIndex && mounted) {
                              setState(() {
                                highlightIndex = index;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DeckButton(
                  onTap: () {
                    widget.onDelete?.call();
                  },
                  child: const Text("DELETE STAY"),
                ),
                DeckButton(
                  onTap: () {
                    widget.onEdit?.call();
                  },
                  child: const Text("EDIT STAY"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
