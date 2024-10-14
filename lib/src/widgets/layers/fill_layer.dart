import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/drawable/drawable.dart';
import 'package:maplibre_flutter_gpu/src/style/tile.dart';
import 'package:maplibre_flutter_gpu/src/widgets/layer_painter.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

class FillLayer extends StatefulWidget {
  const FillLayer({
    super.key,
    required this.layer,
    this.source,
    this.tiledSource,
  });

  final spec.LayerFill layer;
  final spec.Source? source;
  final VectorTiledSource? tiledSource;

  @override
  State<FillLayer> createState() => _FillLayerState();
}

class _FillLayerState extends State<FillLayer> {
  final _drawableCache = <TileCoordinates, FillLayerDrawable>{};

  @override
  void dispose() {
    for (final drawable in _drawableCache.values) {
      drawable.dispose();
    }

    _drawableCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tiledSource != null) {
      return VectorTiledLayerWidget(
        source: widget.tiledSource!,
        drawableResolver: (coordinates) {
          if (_drawableCache.containsKey(coordinates)) return _drawableCache[coordinates];

          final tile = widget.tiledSource!.activeTiles[coordinates];
          if (tile == null) return null;

          final vtLayer = tile.getLayerWithName(widget.layer.sourceLayer!);
          if (vtLayer == null) return null;

          final drawable = FillLayerDrawable(
            coordinates: coordinates,
            vectorTileLayer: vtLayer,
            specLayer: widget.layer,
          );

          _drawableCache[coordinates] = drawable;
          drawable.prepare();

          return drawable;
        },
      );
    }

    return Placeholder();
  }
}
