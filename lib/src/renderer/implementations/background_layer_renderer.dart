import 'dart:ui';

import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

class MapBackgroundLayerRenderer extends MapLayerRenderer<spec.LayerBackground> {
  MapBackgroundLayerRenderer({required super.specLayer});

  @override
  void drawImpl(RendererDrawContext context) {
    final color = specLayer.paint.backgroundColor.evaluate(context.evalContext);

    context.canvas.drawRect(
      Offset.zero & context.size,
      Paint()
        ..color = color.asUiColor
        ..style = PaintingStyle.fill,
    );
  }
}
