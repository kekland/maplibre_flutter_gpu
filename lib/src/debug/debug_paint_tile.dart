import 'dart:math';
import 'dart:ui';

import 'package:dart_earcut/dart_earcut.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart' as vt;

void _drawMultiPointFeature(Canvas canvas, Size size, vt.MultiPointFeature feature) {
  final color = Colors.primaries[(feature.attributes['class']?.hashCode ?? 0) % Colors.primaries.length];

  for (final point in feature.points) {
    canvas.drawCircle(
      point.toOffset(),
      16.0,
      Paint()..color = color,
    );
  }
}

void _drawMultiLineStringFeature(Canvas canvas, Size size, vt.MultiLineStringFeature feature) {
  for (final line in feature.lines) {
    final points = line.points.map((p) => p.toOffset()).toList();

    canvas.drawPoints(
      PointMode.polygon,
      points,
      Paint()
        ..color = Colors.purple
        ..strokeWidth = 1.0,
    );
  }
}

void _drawMultiPolygonFeature(
  Canvas canvas,
  Size size,
  vt.MultiPolygonFeature feature,
  Color color,
) {
  for (final polygon in feature.polygons) {
    final exterior = polygon.exterior.points.map((p) => p.toDoublePoint());
    final interiors = polygon.interiors.map((r) => r.points.map((p) => p.toDoublePoint()));

    final points = <Point<double>>[...exterior];

    final holeIndices = <int>[];

    for (final interior in interiors) {
      holeIndices.add(points.length);
      points.addAll(interior);
    }

    final tris = Earcut.triangulateFromPoints(points, holeIndices: holeIndices);
    final verts = tris.map((i) => points[i]);

    canvas.drawVertices(
      Vertices(
        VertexMode.triangles,
        verts.map((v) => v.toOffset()).toList(),
      ),
      BlendMode.src,
      Paint()..color = color,
    );
  }
}

void debugPaintLayer(
  Canvas canvas,
  Size size,
  vt.Layer layer,
) {
  var i = 0;

  for (final feature in layer.features) {
    final _feature = feature;

    if (_feature is vt.MultiPointFeature) {
      _drawMultiPointFeature(canvas, size, _feature);
    } else if (_feature is vt.MultiLineStringFeature) {
      // _drawMultiLineStringFeature(canvas, size, _feature);
    } else if (_feature is vt.MultiPolygonFeature) {
      // _drawMultiPolygonFeature(
      //   canvas,
      //   size,
      //   _feature,
      //   Colors.primaries[(i++) % Colors.primaries.length],
      // );

      i++;
    }
  }
}

void debugPaintTile(
  Canvas canvas,
  Size size,
  vt.Tile tile,
) {
  return;
  
  for (final layer in tile.layers) {
    debugPaintLayer(
      canvas,
      size,
      layer,
    );
  }
}
