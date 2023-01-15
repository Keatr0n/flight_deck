import 'dart:convert';

import 'package:flight_deck/models/asset_vector_tile_provider.dart';
import 'package:flight_deck/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, required this.locations});

  final List<LatLng> locations;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool isLoading = true;
  late final vtr.Theme theme;
  late final LatLng initialLocation;
  late final double initialZoom;

  List<Marker> _buildMarkers() {
    final output = <Marker>[];

    for (final location in widget.locations) {
      output.add(Marker(
        width: 80.0,
        height: 80.0,
        point: location,
        builder: (ctx) => const Icon(Icons.fullscreen_exit, color: Colors.red),
      ));
    }

    return output;
  }

  @override
  void initState() {
    initialLocation = [
      widget.locations.map((e) => [e.latitude, e.longitude]).reduce((value, element) => [value[0] + element[0], value[1] + element[1]]).map((e) => e / widget.locations.length).toList()
    ].map((e) => LatLng(e[0], e[1])).first;

    final averageDistance = MapUtils.getDistance(initialLocation, widget.locations.first);

    if (averageDistance < 1000) {
      initialZoom = 8;
    } else if (averageDistance < 10000) {
      initialZoom = 5;
    } else if (averageDistance < 1500000) {
      initialZoom = 3;
    } else {
      initialZoom = 1;
    }

    rootBundle.loadString("assets/map_theme.json").then((value) {
      theme = vtr.ThemeReader().read(jsonDecode(value) as Map<String, dynamic>);
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 400,
      width: 400,
      child: FlutterMap(
        options: MapOptions(
          center: initialLocation,
          zoom: initialZoom,
        ),
        children: [
          VectorTileLayer(
            theme: theme,
            tileProviders: TileProviders({"openmaptiles": AssetVectorTileProvider("assets/map_tiles/{z}/{x}/{y}.pbf", 5)}),
          ),
          MarkerLayer(markers: _buildMarkers()),
        ],
      ),
    );
  }
}
