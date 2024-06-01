import 'dart:convert';

import 'package:flight_deck/models/asset_vector_tile_provider.dart';
import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    this.locations,
    this.highlightedIndex,
    this.onTap,
    this.height,
    this.width,
    this.centre,
    this.initialLocation,
    this.mapController,
  });

  final List<MapLocation>? locations;
  final LatLng? centre;
  final int? highlightedIndex;
  final void Function(int? index, LatLng location)? onTap;
  final double? height;
  final double? width;
  final LatLng? initialLocation;
  final MapController? mapController;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool isLoading = true;
  late final vtr.Theme theme;
  late final LatLng initialLocation;
  late final double initialZoom;

  late final MapController mapController;

  List<Marker> _buildMarkers() {
    final output = <Marker>[];

    if (widget.locations == null) {
      return output;
    }

    for (var i = 0; i < widget.locations!.length; i++) {
      output.add(Marker(
        width: i == widget.highlightedIndex ? 110.0 : 80.0,
        height: i == widget.highlightedIndex ? 110.0 : 80.0,
        point: widget.locations![i].location,
        builder: (ctx) => TextButton(
          onPressed: () {
            widget.onTap?.call(i, widget.locations![i].location);
          },
          child: Icon(
            widget.locations![i].icon ?? (i == widget.highlightedIndex ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
            color: Colors.red,
          ),
        ),
      ));
    }

    return output;
  }

  @override
  void initState() {
    LatLng? initialLocationNullable;

    mapController = widget.mapController ?? MapController();

    if (widget.centre != null) {
      initialLocationNullable = widget.centre!;
    }

    if (widget.locations != null && widget.locations!.isNotEmpty) {
      initialLocationNullable ??= [
        widget.locations!
            .map((e) => [e.location.latitude, e.location.longitude])
            .reduce((value, element) => [value[0] + element[0], value[1] + element[1]])
            .map((e) => e / widget.locations!.length)
            .toList()
      ].map((e) => LatLng(e[0], e[1])).first;

      final averageDistance = MapUtils.getDistance(initialLocationNullable, widget.locations!.first.location);

      if (averageDistance < 1000) {
        initialZoom = 8;
      } else if (averageDistance < 10000) {
        initialZoom = 5;
      } else if (averageDistance < 1500000) {
        initialZoom = 3;
      } else {
        initialZoom = 1;
      }
    } else {
      initialZoom = 8;
    }
    initialLocationNullable ??= widget.initialLocation ?? const LatLng(51.5, -0.09);

    initialLocation = initialLocationNullable;

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
      height: widget.height ?? MediaQuery.of(context).size.height * 0.4,
      width: widget.width ?? MediaQuery.of(context).size.width * 0.4,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          interactiveFlags: 31, // everything but rotate
          center: initialLocation,
          zoom: initialZoom,
          onTap: (tapPosition, point) {
            widget.onTap?.call(null, point);
          },
        ),
        children: [
          VectorTileLayer(
            theme: theme,
            tileProviders: TileProviders({"openmaptiles": AssetVectorTileProvider("assets/map_tiles/{z}/{x}/{y}.pbf", 5, 0)}),
          ),
          MarkerLayer(markers: _buildMarkers()),
        ],
      ),
    );
  }
}
