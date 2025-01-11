import 'package:flutter/painting.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_coordinates.dart';
import 'package:maplibre_flutter_gpu/src/debug/sections/render_debug_options_section.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_style_spec/src/gen/style.gen.dart';
import 'dart:ui' as ui;

class DebugRenderStats {
  const DebugRenderStats({this.vertices});

  final int? vertices;
}

class DebugMapTileStatsLayerRenderer extends Renderer {
  DebugMapTileStatsLayerRenderer({required this.orchestrator});

  final RenderOrchestrator orchestrator;

  TextPainter? _textPainter;

  @override
  void drawImpl(RendererDrawContext context) {
    _textPainter ??= TextPainter(textDirection: TextDirection.ltr);

    final tiles = <TileCoordinates, Map<String, DebugRenderStats>>{};

    for (final renderer in orchestrator.renderers) {
      if (renderer is MapVectorTiledLayerRenderer) {
        for (final tile in renderer.tileRenderers.entries) {
          final coordinates = tile.key;
          final renderer = tile.value;

          tiles[coordinates] ??= {};

          if (renderer.debugRenderStats != null && renderer.debugRenderStats!.vertices != null) {
            tiles[coordinates]![renderer.specLayer.id] = renderer.debugRenderStats!;
          }
        }
      }
    }

    if (debugMapShowTileBoundaries) {
      final canvas = context.canvas;

      final paint = ui.Paint()
        ..color = const ui.Color(0x80FF0000)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.save();
      canvas.translate(-context.camera.pixelOrigin.x, -context.camera.pixelOrigin.y);

      for (final coordinates in tiles.keys) {
        final renderers = tiles[coordinates]!;

        _textPainter!.text = TextSpan(
          text: '(${coordinates.z}, ${coordinates.x}, ${coordinates.y})\n${renderers.length} layers',
          style: const TextStyle(
            fontSize: 8.0,
            color: Color(0xFF000000),
          ),
        );

        final size = context.tileSizeCalculator(coordinates);
        final origin = ui.Offset(coordinates.x * size, coordinates.y * size);
        final rect = origin & ui.Size.square(size);

        canvas.save();
        canvas.clipRect(rect);

        context.canvas.drawRect(rect, paint);

        _textPainter!.layout(maxWidth: size / 2.0);
        _textPainter!.paint(context.canvas, origin + const ui.Offset(4, 4));

        canvas.restore();
      }

      canvas.restore();
    }

    if (debugMapShowRenderStats) {
      final _vertsByLayer = <String, int>{};
      for (final renderers in tiles.values) {
        for (final renderer in renderers.entries) {
          _vertsByLayer[renderer.key] = (_vertsByLayer[renderer.key] ?? 0) + (renderer.value.vertices ?? 0);
        }
      }

      final total = _vertsByLayer.values.fold<int>(0, (sum, value) => sum + value);
      final sortedLayers = _vertsByLayer.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      var text = sortedLayers.map((entry) => '${entry.key}: ${entry.value} verts').join('\n');
      text += '\n\nTotal: $total verts';

      _textPainter!.text = TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 8.0,
          color: Color(0xFF000000),
        ),
      );

      _textPainter!.layout(maxWidth: 320.0);

      context.canvas.drawRect(
        ui.Rect.fromLTWH(
          4,
          context.size.height - 12 - _textPainter!.height,
          320,
          _textPainter!.height + 8,
        ),
        ui.Paint()..color = const Color(0x36000000),
      );

      _textPainter!.paint(
        context.canvas,
        context.size.bottomLeft(Offset.zero) - ui.Offset(-8, 8 + _textPainter!.height),
      );
    }
  }
}
