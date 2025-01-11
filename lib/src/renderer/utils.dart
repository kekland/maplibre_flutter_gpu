import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

List<T> filterFeatures<T extends vt.Feature>(
  TileCoordinates coordinates,
  vt.Layer vtLayer,
  spec.Layer specLayer,
  spec.EvaluationContext evalContext,
) {
  return vtLayer.features.whereType<T>().where((feature) {
    if (specLayer.minzoom != null) {
      if (coordinates.z < specLayer.minzoom!) return false;
    }

    if (specLayer.maxzoom != null) {
      if (coordinates.z > specLayer.maxzoom!) return false;
    }

    if (specLayer.filter == null) return true;

    try {
      return specLayer.filter!(evalContext.extendWith(properties: feature.attributes));
    } catch (e) {
      return false;
    }
  }).toList();
}
