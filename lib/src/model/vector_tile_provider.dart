import 'dart:async';

import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
import 'package:maplibre_flutter_gpu/src/components/rendering/drawable.dart';
import 'package:maplibre_flutter_gpu/src/components/rendering/implementations/line_layer_drawable.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

class VectorTileProvider {
  VectorTileProvider({
    required this.coordinates,
    required this.zoomOffset,
    required this.sources,
    required this.style,
  });

  final TileCoordinates coordinates;
  final double zoomOffset;
  final List<VectorTiledSource> sources;
  final spec.Style style;

  Future<List<Drawable>?> load(Completer<void> cancelLoading) async {
    final vectorTiles = await Future.wait(sources.map((v) => v.loadTile(coordinates)));
    if (cancelLoading.isCompleted) return null;

    final drawables = <Drawable>[];

    final prepareFutures = <Future>[];

    for (final layer in style.layers) {
      if (layer.type == spec.Layer$Type.background) continue;

      final sourceIndex = sources.indexWhere((s) => s.key == layer.source);

      final vt = vectorTiles[sourceIndex];
      final vtLayer = vt.getLayerWithName(layer.sourceLayer!);

      if (vtLayer == null) continue;

      Drawable? drawable;

      if (layer.type == spec.Layer$Type.fill) {
        drawable = FillLayerDrawable(
          vectorTileLayer: vtLayer,
          specLayer: layer as spec.LayerFill,
          coordinates: coordinates,
        );
      }

      if (layer.type == spec.Layer$Type.line) {
        drawable = LineLayerDrawable(
          vectorTileLayer: vtLayer,
          specLayer: layer as spec.LayerLine,
          coordinates: coordinates,
        );
      }

      if (drawable != null) {
        // TODO: Move prepare to a separate place.
        prepareFutures.add(drawable.prepare(gpuContext, spec.EvaluationContext.empty()));
        drawables.add(drawable);
      }
    }

    await Future.wait(prepareFutures);
    if (cancelLoading.isCompleted) return null;

    return drawables;
  }
}
