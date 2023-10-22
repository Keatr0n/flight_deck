import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:vector_map_tiles/vector_map_tiles.dart';

/// asset path should look something like this
/// assets/map_tiles/{z}/{x}/{y}.pbf
class AssetVectorTileProvider extends VectorTileProvider {
  AssetVectorTileProvider(this._assetPath, this._maximumZoom, this._minimumZoom);
  final int _maximumZoom;
  final int _minimumZoom;
  final String _assetPath;

  @override
  int get maximumZoom => _maximumZoom;
  @override
  int get minimumZoom => _minimumZoom;

  @override
  Future<Uint8List> provide(TileIdentity tile) {
    final path = _assetPath.replaceAllMapped(RegExp(r'\{(x|y|z)\}'), (match) {
      switch (match.group(1)) {
        case 'x':
          return tile.x.toString();
        case 'y':
          return tile.y.toString();
        case 'z':
          return tile.z.toString();
        default:
          throw Exception('unexpected url template: $_assetPath - token ${match.group(1)} is not supported');
      }
    });

    return rootBundle.load(path).then((value) => value.buffer.asUint8List());
  }
}
