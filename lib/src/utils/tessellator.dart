import 'dart:math';

import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart' as vt;
import 'package:dart_earcut/dart_earcut.dart' as earcut;

class Tessellator {
  static List<int> tessellatePolygon(vt.Polygon polygon) {
    final vertices = <Point<int>>[];
    final holeIndices = <int>[];

    vertices.addAll(polygon.exterior.points);

    for (final interiorRing in polygon.interiors) {
      holeIndices.add(vertices.length);
      vertices.addAll(interiorRing.points);
    }

    return earcut.Earcut.triangulateFromPoints(
      vertices.map((p) => Point<double>(p.x.toDouble(), p.y.toDouble())),
      holeIndices: holeIndices,
    );
  }
}
