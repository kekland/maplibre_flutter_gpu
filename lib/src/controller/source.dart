import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:maplibre_flutter_gpu/src/components/utils/zoned_http_client.dart';
import 'package:maplibre_flutter_gpu/src/controller/tile_bucket.dart';

import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range_calculator.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;

final _logger = Logger('Source');

abstract class Source<TSource extends spec.Source> {
  Source({required this.key, required this.specSource});

  final Object key;
  final TSource specSource;

  void dispose() {}
}

abstract class TiledSource<TSource extends spec.Source, TTile> extends Source<TSource> {
  TiledSource({
    required super.key,
    required super.specSource,
    required this.visibleTileBucket,
  });

  final TileBucket<TTile> visibleTileBucket;

  int? get minZoom;
  int? get maxZoom;
  fm.LatLngBounds? get bounds;

  TileRangeCalculator? _tileRangeCalculator;
  TileBounds? _tileBounds;

  Set<fm.TileCoordinates>? _lastValidCoordinates;

  void onCameraChanged(fm.MapCamera camera, double tileSize) {
    _tileRangeCalculator ??= TileRangeCalculator(tileSize: tileSize);
    _tileBounds ??= TileBounds(crs: camera.crs, tileSize: tileSize, latLngBounds: bounds);

    final zoom = camera.zoom;
    final tileZoom = zoom.floor().clamp(minZoom!, maxZoom!);
    final tileBoundsAtZoom = _tileBounds!.atZoom(tileZoom);

    _lastValidCoordinates = tileBoundsAtZoom
        .validCoordinatesIn(_tileRangeCalculator!.calculate(camera: camera, tileZoom: tileZoom))
        .map(_wrapTileCoordinates)
        .toSet();

    final missingTiles = visibleTileBucket.keepVisibleRange(_lastValidCoordinates!);
    if (missingTiles.isEmpty) return;

    _logger.fine('onCameraChanged, ${missingTiles.length} tiles to load');
    for (final coordinates in missingTiles) {
      loadTile(coordinates);
    }
  }

  final _inProgressTiles = <fm.TileCoordinates>{};
  Future<void> loadTile(fm.TileCoordinates coordinates) async {
    if (_inProgressTiles.contains(coordinates)) return;
    _inProgressTiles.add(coordinates);

    try {
      final tile = await loadTileImpl(coordinates);
      visibleTileBucket.addTile(coordinates, tile);
    } catch (e) {
      _logger.warning('Failed to load tile $coordinates: $e');
    } finally {
      _inProgressTiles.remove(coordinates);
    }
  }

  Future<TTile> loadTileImpl(fm.TileCoordinates coordinates);

  @override
  void dispose() {
    visibleTileBucket.dispose();
  }
}

class VectorTiledSource extends TiledSource<spec.SourceVector, vt.Tile> {
  VectorTiledSource({required super.key, required super.specSource})
      : super(visibleTileBucket: VectorTileBucket(key: key, source: specSource));

  @override
  int get minZoom => specSource.minzoom.toInt();

  @override
  int get maxZoom => specSource.maxzoom.toInt();

  @override
  fm.LatLngBounds get bounds => fm.LatLngBounds(
        LatLng(specSource.bounds[1].toDouble(), specSource.bounds[0].toDouble()),
        LatLng(specSource.bounds[3].toDouble(), specSource.bounds[2].toDouble()),
      );

  @override
  Future<vt.Tile> loadTileImpl(fm.TileCoordinates coordinates) async {
    final response = await zonedHttpGet(_getTileUri(specSource.tiles!.first, coordinates));
    final pbData = pb.Tile.fromBuffer(response.bodyBytes);

    return vt.Tile.parse(pbData);
  }
}

Uri _getTileUri(String sourceUrl, fm.TileCoordinates coordinates) {
  return Uri.parse(
    sourceUrl
        .replaceFirst('{z}', coordinates.z.toString())
        .replaceFirst('{x}', coordinates.x.toString())
        .replaceFirst('{y}', coordinates.y.toString()),
  );
}

fm.TileCoordinates _wrapTileCoordinates(fm.TileCoordinates coordinates) {
  if (coordinates.z < 0) {
    return coordinates;
  }
  final modulo = 1 << coordinates.z;
  int x = coordinates.x;
  while (x < 0) {
    x += modulo;
  }
  while (x >= modulo) {
    x -= modulo;
  }
  int y = coordinates.y;
  while (y < 0) {
    y += modulo;
  }
  while (y >= modulo) {
    y -= modulo;
  }
  return fm.TileCoordinates(x, y, coordinates.z);
}
