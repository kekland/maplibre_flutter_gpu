import 'package:flutter/widgets.dart' hide Matrix4;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_map/flutter_map.dart';

import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart';

export 'implementations/fill_layer_drawable.dart';

abstract class Drawable {
  bool _isReady = false;

  Future<void> prepare(
    gpu.GpuContext context,
    spec.EvaluationContext evalContext,
  ) async {
    _isReady = await prepareImpl(context, evalContext);
  }

  void draw(
    Canvas canvas,
    gpu.GpuContext context,
    spec.EvaluationContext evalContext,
    Matrix4 camera,
    gpu.RenderPass pass,
  ) {
    if (!_isReady) return;
    drawImpl(canvas, context, evalContext, pass, camera);
  }

  Future<bool> prepareImpl(
    gpu.GpuContext context,
    spec.EvaluationContext evalContext,
  );

  void drawImpl(
    Canvas canvas,
    gpu.GpuContext context,
    spec.EvaluationContext evalContext,
    gpu.RenderPass pass,
    Matrix4 camera,
  );
}

abstract class TileDrawable extends Drawable {
  TileDrawable({
    required this.coordinates,
    required this.extent,
  });

  final TileCoordinates coordinates;
  final double extent;
}

abstract class TileLayerDrawable<T extends spec.Layer> extends TileDrawable {
  TileLayerDrawable({
    required this.vectorTileLayer,
    required this.specLayer,
    required super.coordinates,
  }) : super(extent: vectorTileLayer.extent.toDouble());

  final vt.Layer vectorTileLayer;
  final T specLayer;
}
