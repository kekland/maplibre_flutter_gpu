import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpu_vector_tile_renderer/_controller.dart';
import 'package:gpu_vector_tile_renderer/_vector_tile.dart' as vt;
import 'package:gpu_vector_tile_renderer/src/utils/flutter_map/tile_scale_calculator.dart';

class MapDebugPainter extends CustomPainter {
  MapDebugPainter({required this.camera, required this.controller, required this.tileDimension})
    : super(repaint: controller);

  final MapCamera camera;
  final int tileDimension;
  final VectorTileLayerController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final tileScaleCalculator = TileScaleCalculator(crs: camera.crs, tileDimension: tileDimension);
    tileScaleCalculator.clearCacheUnlessZoomMatches(camera.zoom);

    for (final tile in controller.tiles) {
      if (tile.isLoaded) {
        final vt = tile.vectorTiles.values.first;
        final tileDimension = tileScaleCalculator.scaledTileDimension(camera.zoom, tile.coordinates.z);
        final origin = Offset(
          tile.coordinates.x * tileDimension - camera.pixelOrigin.dx,
          tile.coordinates.y * tileDimension - camera.pixelOrigin.dy,
        );

        final transform =
            Matrix4.identity()
              ..translate(origin.dx, origin.dy)
              ..scale(tileDimension / vt.layers.first.extent, tileDimension / vt.layers.first.extent);

        canvas.drawRect(
          Rect.fromLTWH(origin.dx, origin.dy, tileDimension, tileDimension),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.2)
            ..style = PaintingStyle.stroke,
        );

        canvas.save();
        canvas.transform(transform.storage);
        canvas.clipRect(Rect.fromLTWH(0, 0, vt.layers.first.extent.toDouble(), vt.layers.first.extent.toDouble()));
        debugPaintTile(canvas, size, vt);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void _drawPointFeature(Canvas canvas, Size size, vt.PointFeature feature, Color color) {
  for (final point in feature.points) {
    canvas.drawCircle(point, 16.0, Paint()..color = color);
  }
}

void _drawLines(Canvas canvas, Size size, List<Offset> points, Color color) {
  canvas.drawPoints(
    PointMode.polygon,
    points,
    Paint()
      ..color = color
      ..strokeWidth = 1.0,
  );
}

void _drawLineStringFeature(Canvas canvas, Size size, vt.LineStringFeature feature, Color color) {
  for (final line in feature.lines) {
    _drawLines(canvas, size, line.points, color);
  }
}

void _drawPolygonFeature(Canvas canvas, Size size, vt.PolygonFeature feature, Color color) {
  for (final polygon in feature.polygons) {
    _drawLines(canvas, size, polygon.exterior.points, color);

    for (final interior in polygon.interiors) {
      _drawLines(canvas, size, interior.points, color.withValues(alpha: 0.25));
    }
  }
}

void debugPaintLayer(Canvas canvas, Size size, vt.Layer layer, Color color) {
  for (final feature in layer.features) {
    final _feature = feature;

    if (_feature is vt.PointFeature) {
      _drawPointFeature(canvas, size, _feature, color);
    } else if (_feature is vt.LineStringFeature) {
      _drawLineStringFeature(canvas, size, _feature, color);
    } else if (_feature is vt.PolygonFeature) {
      _drawPolygonFeature(canvas, size, _feature, color);
    }
  }
}

void debugPaintTile(Canvas canvas, Size size, vt.Tile tile) {
  for (var i = 0; i < tile.layers.length; i++) {
    final layer = tile.layers[i];
    final color = Colors.primaries[i % Colors.primaries.length];

    debugPaintLayer(canvas, size, layer, color);
  }
}
