// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_gpu/gpu.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
// import 'package:maplibre_flutter_gpu/src/components/rendering/drawable.dart';
// import 'package:maplibre_flutter_gpu/src/components/rendering/implementations/line_layer_drawable.dart';
// import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

// class LoadedStyle with ChangeNotifier {
//   LoadedStyle({
//     required this.style,
//     required this.resolvedTiledSources,
//   }) {
//     for (final source in resolvedTiledSources.values) {
//       source.onTileChangedCallback = _onTileChanged;
//       source.addListener(notifyListeners);
//     }
//   }

//   final spec.Style style;
//   final Map<Object, TiledSource> resolvedTiledSources;
//   final Map<(Object, String, String, TileCoordinates), TileDrawable> tileDrawables = {};

//   Iterable<VectorTile> get activeVectorTiles => resolvedTiledSources.values
//       .whereType<VectorTiledSource>()
//       .expand((source) => source.activeTiles.values)
//       .cast<VectorTile>();

//   Set<TileCoordinates> _visibleTiles = {};
//   Future<void> onVisibleTilesChanged(Set<TileCoordinates> visibleTiles) async {
//     if (setEquals(_visibleTiles, visibleTiles)) return;
//     _visibleTiles = visibleTiles;

//     for (final source in resolvedTiledSources.values) {
//       source.onVisibleTilesChanged(visibleTiles);
//     }
//   }

//   void _onTileChanged(Tile tile) {
//     if (tile is VectorTile) {
//       for (final layer in style.layers) {
//         if (layer.sourceLayer == null) continue;

//         final key = (tile.sourceKey, layer.id, layer.sourceLayer!, tile.coordinates);
//         final vtLayer = tile.getLayerWithName(layer.sourceLayer!);

//         if (vtLayer == null) continue;

//         if (layer.type == spec.Layer$Type.fill) {
//           tileDrawables[key] = FillLayerDrawable(
//             vectorTileLayer: vtLayer,
//             specLayer: layer as spec.LayerFill,
//             coordinates: tile.coordinates,
//           );

//           tileDrawables[key]!.prepare(gpuContext, spec.EvaluationContext.empty());
//         }

//         if (layer.type == spec.Layer$Type.line) {
//           tileDrawables[key] = LineLayerDrawable(
//             vectorTileLayer: vtLayer,
//             specLayer: layer as spec.LayerLine,
//             coordinates: tile.coordinates,
//           );

//           tileDrawables[key]!.prepare(gpuContext, spec.EvaluationContext.empty());
//         }
//       }
//     }
//   }

//   // List<TileDrawable> computeTileDrawables() {
//   //   final result = <TileDrawable>[];

//   //   List<TileCoordinates> missingTiles = [];
//   //   for (final coordinates in _visibleTiles) {
//   //     final drawables = _tileDrawables.entries.where((e) => e.key.$3 == coordinates);
//   //   }
//   // }

//   @override
//   void dispose() {
//     for (final source in resolvedTiledSources.values) {
//       source.dispose();
//     }

//     super.dispose();
//   }
// }
