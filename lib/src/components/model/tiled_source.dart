import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/utils/zoned_http_client.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

abstract class TiledSource<S extends spec.Source, T extends Tile> {
  TiledSource({
    required this.key,
    required this.source,
    required this.tileResolver,
  });

  final Object key;
  final S source;
  final TileResolverFunction tileResolver;

  bool get isVolatile;

  bool containsCoordinates(TileCoordinates coordinates);

  Future<T> loadTile(TileCoordinates coordinates) async {
    final tile = (await tileResolver(key, source, coordinates)) as T;
    return tile;
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

  @override
  bool containsCoordinates(TileCoordinates coordinates) {
    return coordinates.z >= source.minzoom && coordinates.z <= source.maxzoom;
  }
}

typedef TileResolverFunction = Future<Tile> Function(Object sourceKey, spec.Source source, TileCoordinates coordinates);

Future<Tile> defaultTileResolver(Object sourceKey, spec.Source source, TileCoordinates coordinates) {
  return switch (source) {
    spec.SourceVector vector => _defaultVectorTileResolver(sourceKey, vector, coordinates),
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
  final response = await zonedHttpGet(_getTileUri(source.tiles!.first, coordinates));
  final pbData = pb.Tile.fromBuffer(response.bodyBytes);
  final data = vt.Tile.parse(pbData);

  return VectorTile(
    sourceKey: sourceKey,
    coordinates: coordinates,
    data: data,
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
