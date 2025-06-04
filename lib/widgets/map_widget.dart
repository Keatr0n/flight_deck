import 'dart:async';
import 'dart:convert';

import 'package:flight_deck/models/app_state_memory.dart';
import 'package:flight_deck/models/asset_vector_tile_provider.dart';
import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/models/map_location.dart';
import 'package:flight_deck/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
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
    this.geoJson,
  });

  final List<MapLocation>? locations;
  final LatLng? centre;
  final int? highlightedIndex;
  final void Function(int? index, LatLng location)? onTap;
  final double? height;
  final double? width;
  final LatLng? initialLocation;
  final MapController? mapController;
  final Map<String, dynamic>? geoJson;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool isLoading = true;
  late final vtr.Theme theme;
  late final LatLng initialLocation;
  late final double initialZoom;
  List<Marker> markers = [];

  late final MapController mapController;

  late final StreamSubscription mapEventStream;
  Timer moveDebouncer = Timer(const Duration(seconds: 1), () {});

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
        child: TextButton(
          onPressed: () {
            widget.onTap?.call(i, widget.locations![i].location);
          },
          child: Icon(
            widget.locations![i].icon ??
                (i == widget.highlightedIndex ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
            color: Colors.red,
          ),
        ),
      ));
    }

    try {
      output.removeWhere((element) => !(mapController.camera.visibleBounds.contains(element.point)));
    } catch (e) {
      // it just hasn't been initialised yet
    }

    if (output.length > 100) {
      try {
        output.sort((a, b) => MapUtils.getDistance(a.point, mapController.camera.center)
            .compareTo(MapUtils.getDistance(b.point, mapController.camera.center)));
      } catch (e) {
        // again, hasn't been initialised
        output.sort((a, b) =>
            MapUtils.getDistance(a.point, initialLocation).compareTo(MapUtils.getDistance(b.point, initialLocation)));
      }

      output.removeRange(100, output.length);
    }

    return output;
  }

  @override
  void initState() {
    LatLng? initialLocationNullable;

    mapController = widget.mapController ?? MapController();

    mapEventStream = mapController.mapEventStream.listen((event) {
      moveDebouncer.cancel();
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventFlingAnimationNotStarted ||
          event is MapEventScrollWheelZoom) {
        moveDebouncer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            FlightDeckDB.instance
                .updateAppStateMemory(AppStateMemory((mapController.camera.center, mapController.camera.zoom)));
            setState(() {
              markers = _buildMarkers();
            });
          }
        });
      }
    });

    if (widget.centre != null) {
      initialLocationNullable = widget.centre;
      initialZoom = 8;
    } else if (FlightDeckDB.instance.appStateMemory.lastMapLocation != null) {
      initialLocationNullable = FlightDeckDB.instance.appStateMemory.lastMapLocation!.$1;
      initialZoom = FlightDeckDB.instance.appStateMemory.lastMapLocation!.$2;
    } else if (widget.locations != null && widget.locations!.isNotEmpty) {
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

    markers = _buildMarkers();

    rootBundle.loadString("assets/map_theme.json").then((value) {
      theme = vtr.ThemeReader().read(jsonDecode(value) as Map<String, dynamic>);
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    mapEventStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final geoJson = GeoJsonParser(
      defaultPolygonFillColor: const Color(0x13E90808),
      defaultCircleMarkerBorderColor: const Color(0x22E90808),
      defaultPolygonBorderColor: const Color(0x22E90808),
      defaultPolylineColor: const Color(0x22E90808),
    );

    if (widget.geoJson != null) {
      geoJson.parseGeoJson(widget.geoJson!);
    }

    return SizedBox(
      height: widget.height ?? MediaQuery.of(context).size.height * 0.4,
      width: widget.width ?? MediaQuery.of(context).size.width * 0.4,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          interactionOptions: const InteractionOptions(flags: 31), // everything but rotate
          initialCenter: initialLocation,
          initialZoom: initialZoom,
          onTap: (tapPosition, point) {
            widget.onTap?.call(null, point);
          },
        ),
        children: [
          VectorTileLayer(
            theme: theme,
            tileProviders:
                TileProviders({"openmaptiles": AssetVectorTileProvider("assets/map_tiles/{z}/{x}/{y}.pbf", 6, 0)}),
          ),
          if (geoJson.polygons.isNotEmpty)
            PolygonLayer(
              polygons: geoJson.polygons,
            ),
          if (geoJson.polylines.isNotEmpty) PolylineLayer(polylines: geoJson.polylines),
          if (geoJson.circles.isNotEmpty) CircleLayer(circles: geoJson.circles),
          if (geoJson.markers.isNotEmpty) MarkerLayer(markers: geoJson.markers),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
