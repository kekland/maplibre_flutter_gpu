import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/utils/http_utils.dart';
import 'package:maplibre_flutter_gpu/src/utils/image_utils.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

abstract class TiledSource<S extends spec.Source, T extends Tile> with ChangeNotifier {
  TiledSource({
    required this.key,
    required this.source,
    required this.tileResolver,
  });

  final Object key;
  final S source;
  final TileResolver tileResolver;

  final Set<TileCoordinates> _visibleTiles = {};
  final Map<TileCoordinates, T> activeTiles = {};
  final Map<TileCoordinates, T> _tileCache = {};

  bool get isVolatile;

  void onVisibleTilesChanged(Set<TileCoordinates> tiles) {
    if (setEquals(_visibleTiles, tiles)) return;

    _visibleTiles.clear();
    _visibleTiles.addAll(tiles);

    activeTiles.removeWhere((key, value) => !tiles.contains(key));
    final missingTiles = tiles.where((tile) => !activeTiles.containsKey(tile)).toList();

    for (final coordinates in missingTiles) {
      if (!isVolatile && _tileCache.containsKey(coordinates)) {
        activeTiles[coordinates] = _tileCache.remove(coordinates)!;
      } else {
        _loadTile(coordinates);
      }
    }
  }

  Future<void> _loadTile(TileCoordinates coordinates) async {
    final tile = await tileResolver(key, source, coordinates) as T;

    if (!isVolatile) _tileCache[coordinates] = tile;

    if (_visibleTiles.contains(coordinates)) {
      activeTiles[coordinates] = tile;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final tile in activeTiles.values) tile.dispose();
    for (final tile in _tileCache.values) tile.dispose();

    super.dispose();
  }
}

class VectorTiledSource extends TiledSource<spec.SourceVector, VectorTile> {
  VectorTiledSource({
    required super.key,
    required super.source,
    required super.tileResolver,
  });

  @override
  bool get isVolatile => source.volatile;
}

class RasterTiledSource extends TiledSource<spec.SourceRaster, RasterTile> {
  RasterTiledSource({
    required super.key,
    required super.source,
    required super.tileResolver,
  });

  @override
  bool get isVolatile => source.volatile;
}

class RasterDemTiledSource extends TiledSource<spec.SourceRasterDem, RasterTile> {
  RasterDemTiledSource({
    required super.key,
    required super.source,
    required super.tileResolver,
  });

  @override
  bool get isVolatile => source.volatile;
}

typedef TileResolver = Future<Tile> Function(Object sourceKey, spec.Source source, TileCoordinates coordinates);

Future<Tile> defaultTileResolver(Object sourceKey, spec.Source source, TileCoordinates coordinates) {
  return switch (source) {
    spec.SourceVector vector => _defaultVectorTileResolver(sourceKey, vector, coordinates),
    spec.SourceRaster raster => _defaultRasterTileResolver(sourceKey, raster, coordinates),
    spec.SourceRasterDem rasterDem => _defaultRasterDemTileResolver(sourceKey, rasterDem, coordinates),
    _ => throw Exception('Unsupported tiled source type: $source'),
  };
}

Uri _getTileUri(String sourceUrl, TileCoordinates coordinates) {
  return Uri.parse(
    sourceUrl
        .replaceFirst('{z}', coordinates.z.toString())
        .replaceFirst('{x}', coordinates.x.toString())
        .replaceFirst('{y}', coordinates.y.toString()),
  );
}

Future<Tile> _defaultVectorTileResolver(Object sourceKey, spec.SourceVector source, TileCoordinates coordinates) async {
  final response = await httpGet(_getTileUri(source.tiles!.first, coordinates));
  final pbData = pb.Tile.fromBuffer(response.bodyBytes);
  final data = vt.Tile.parse(pbData);

  return VectorTile(
    sourceKey: sourceKey,
    coordinates: coordinates,
    data: data,
  );
}

Future<Tile> _defaultRasterTileResolver(Object sourceKey, spec.SourceRaster source, TileCoordinates coordinates) async {
  final response = await httpGet(_getTileUri(source.url!, coordinates));
  final image = await decodeImageFromListAsync(response.bodyBytes);

  return RasterTile(
    sourceKey: sourceKey,
    coordinates: coordinates,
    image: image,
  );
}

Future<Tile> _defaultRasterDemTileResolver(
  Object sourceKey,
  spec.SourceRasterDem source,
  TileCoordinates coordinates,
) async {
  final response = await httpGet(_getTileUri(source.url!, coordinates));
  final image = await decodeImageFromListAsync(response.bodyBytes);

  return RasterTile(
    sourceKey: sourceKey,
    coordinates: coordinates,
    image: image,
  );
}

abstract class Tile {
  const Tile({
    required this.sourceKey,
    required this.coordinates,
  });

  final Object sourceKey;
  final TileCoordinates coordinates;

  void dispose() {}

  @override
  int get hashCode => Object.hash(sourceKey, coordinates);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile && sourceKey == other.sourceKey && coordinates == other.coordinates;
  }
}

class VectorTile extends Tile {
  const VectorTile({
    required super.sourceKey,
    required super.coordinates,
    required this.data,
  });

  final vt.Tile data;

  vt.Layer? getLayerWithName(String name) {
    return data.layers.firstWhereOrNull((layer) => layer.name == name);
  }
}

class RasterTile extends Tile {
  const RasterTile({
    required super.sourceKey,
    required super.coordinates,
    required this.image,
  });

  final ui.Image image;

  @override
  void dispose() {
    image.dispose();
  }
}
