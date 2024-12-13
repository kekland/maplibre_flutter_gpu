import 'dart:convert';

import 'package:maplibre_flutter_gpu/src/components/utils/zoned_http_client.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

typedef SourceResolverFunction = Future<spec.Source> Function(spec.Source source);

Future<spec.Source> defaultSourceResolver(spec.Source source) async {
  return switch (source) {
    spec.SourceVector vector => _defaultVectorSourceResolver(vector),
    spec.SourceRaster raster => _defaultRasterSourceResolver(raster),
    spec.SourceRasterDem rasterDem => _defaultRasterDemSourceResolver(rasterDem),
    spec.SourceGeoJson geoJson => geoJson,
    spec.SourceImage image => image,
    spec.SourceVideo video => video,
  };
}

Future<spec.TileJson> _loadTileJson(Uri uri) async {
  final response = await zonedHttpClient.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Failed to load TileJSON: ${response.statusCode}');
  }

  return spec.TileJson.fromJson(jsonDecode(response.body));
}

Future<spec.SourceVector> _defaultVectorSourceResolver(spec.SourceVector source) async {
  if (source.tiles != null) return source;
  if (source.url != null) {
    final tileJson = await _loadTileJson(Uri.parse(source.url!));
    return source.copyWith(tiles: tileJson.tiles);
  }

  return source;
}

Future<spec.SourceRaster> _defaultRasterSourceResolver(spec.SourceRaster source) async {
  if (source.tiles != null) return source;

  final tileJson = await _loadTileJson(Uri.parse(source.url!));
  return source.copyWith(tiles: tileJson.tiles);
}

Future<spec.SourceRasterDem> _defaultRasterDemSourceResolver(spec.SourceRasterDem source) async {
  if (source.tiles != null) return source;

  final tileJson = await _loadTileJson(Uri.parse(source.url!));
  return source.copyWith(tiles: tileJson.tiles);
}
