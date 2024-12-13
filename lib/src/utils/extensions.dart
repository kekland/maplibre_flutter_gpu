import 'dart:math';
import 'dart:ui' as ui;

import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart' as vt;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

extension SourceExtensions on spec.Source {
  bool get isTiled {
    if (this is! spec.SourceVector) return false;
    return (this as spec.SourceVector).tiles?.isNotEmpty == true;
  }

  TiledSource createTiledSource(Object key, TileResolverFunction resolver) {
    assert(isTiled);

    if (this is spec.SourceVector) {
      return VectorTiledSource(
        key: key,
        source: this as spec.SourceVector,
        tileResolver: resolver,
      );
    } else {
      throw UnimplementedError('Unsupported source type: $this');
    }
  }
}

extension SpecColorExtensions on spec.Color {
  ui.Color get asUiColor => ui.Color.from(alpha: a, red: r, green: g, blue: b, colorSpace: ui.ColorSpace.sRGB);
}

extension PolygonExtensions on vt.Polygon {
  int get vertexCount {
    var count = exterior.points.length;

    for (final interior in interiors) {
      count += interior.points.length;
    }

    return count;
  }

  Iterable<Point<int>> get vertices sync* {
    yield* exterior.points;

    for (final interior in interiors) {
      yield* interior.points;
    }
  }
}

extension PolygonListExtensions on List<vt.Polygon> {
  int get vertexCount {
    var count = 0;

    for (final polygon in this) {
      count += polygon.vertexCount;
    }

    return count;
  }
}
