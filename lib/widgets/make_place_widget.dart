import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/models/place.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MakePlaceWidget extends StatefulWidget {
  const MakePlaceWidget({super.key, this.onDone, this.initialLocation});
  final void Function(Place newPlace)? onDone;
  final LatLng? initialLocation;

  @override
  State<MakePlaceWidget> createState() => _MakePlaceWidgetState();
}

class _MakePlaceWidgetState extends State<MakePlaceWidget> {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final addressController = TextEditingController();

  LatLng location = const LatLng(0, 0);

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (location.latitude == 0 && location.longitude == 0) {
      location = widget.initialLocation ?? const LatLng(0, 0);
    }

    return DeckWindow(
      onClose: Navigator.of(context).pop,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFFE90808)),
                  decoration: const InputDecoration(
                    label: Text("NAME"),
                    labelStyle: TextStyle(color: Color(0xFFE90808)),
                    fillColor: Colors.black26,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 5,
                  style: const TextStyle(color: Color(0xFFE90808)),
                  decoration: const InputDecoration(
                    label: Text("NOTES"),
                    labelStyle: TextStyle(color: Color(0xFFE90808)),
                    fillColor: Colors.black26,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  style: const TextStyle(color: Color(0xFFE90808)),
                  decoration: const InputDecoration(
                    label: Text("ADDRESS"),
                    labelStyle: TextStyle(color: Color(0xFFE90808)),
                    fillColor: Colors.black26,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                MapWidget(
                  width: MediaQuery.of(context).size.width,
                  initialLocation: widget.initialLocation,
                  locations: [MapLocation.pointOnMap(location)],
                  onTap: (_, location) {
                    this.location = location;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                DeckButton(
                  onTap: () {
                    final newPlace = Place(
                      name: nameController.text,
                      notes: notesController.text,
                      location: location,
                      address: addressController.text,
                    );
                    widget.onDone?.call(newPlace);
                    Navigator.of(context).pop();
                  },
                  child: const Text("DONE"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
