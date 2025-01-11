import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/controller/tile_bucket.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/utils.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/tile.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;

class MapSymbolLayerRenderer extends Renderer with TileBucketListener<vt.Tile> {
  MapSymbolLayerRenderer({required this.specLayer, required this.tileBucket}) {
    tileBucket.addListener(this);
  }

  final spec.LayerSymbol specLayer;
  final TileBucket<vt.Tile> tileBucket;
  final Map<TileCoordinates, vt.Layer> layers = {};

  @override
  void onTileAdded(TileCoordinates coordinates, Tile tile) {
    final vtLayer = tile.layers.firstWhereOrNull((l) => l.name == specLayer.sourceLayer);
    if (vtLayer == null) return;

    layers[coordinates] = vtLayer;
  }

  @override
  void onTileRemoved(TileCoordinates coordinates) {
    layers.remove(coordinates);
  }

  @override
  void drawImpl(RendererDrawContext context) {
    return;
    final canvas = context.canvas;

    for (final entry in layers.entries) {
      final coordinates = entry.key;
      final vtLayer = entry.value;

      final evalContext = context.evalContext;
      final layerFeatures = filterFeatures<vt.Feature>(coordinates, vtLayer, specLayer, evalContext);

      for (final feature in layerFeatures) {
        // for (final point in feature.points) {
        //   canvas.drawCircle(
        //     Offset(point.x.toDouble(), point.y.toDouble()),
        //     32.0,
        //     Paint()
        //       ..color = Colors.primaries[specLayer.id.hashCode % Colors.primaries.length]
        //       ..style = PaintingStyle.fill,
        //   );
        // }
      }
    }
  }
}
