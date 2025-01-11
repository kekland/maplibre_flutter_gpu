import 'dart:math';

import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;
import 'package:maplibre_flutter_gpu/src/vector_tile/model/geometry.dart';
import 'package:fixnum/fixnum.dart' as fixnum;

abstract class Feature {
  Feature(this.attributes);

  final Map<String, Object> attributes;

  /// Parses a feature from a `Tile_Feature` message.
  factory Feature.parse(
    pb.Tile_Feature feature, {
    required List<String> keys,
    required List<Object> values,
  }) {
    final attributes = <String, Object>{};

    for (var i = 0; i < feature.tags.length; i += 2) {
      final keyIndex = feature.tags[i];
      final valueIndex = feature.tags[i + 1];

      // Convert the value from Protobuf types to Dart types.
      final pbValue = values[valueIndex];
      final dartValue = switch (pbValue) {
        fixnum.Int32 v => v.toInt(),
        fixnum.Int64 v => v.toInt(),
        _ => pbValue,
      };

      attributes[keys[keyIndex]] = dartValue;
    }

    return switch (feature.type) {
      pb.Tile_GeomType.POINT => _parsePointFeature(feature, attributes),
      pb.Tile_GeomType.LINESTRING => _parseLineStringFeature(feature, attributes),
      pb.Tile_GeomType.POLYGON => _parsePolygonFeature(feature, attributes),
      pb.Tile_GeomType.UNKNOWN => throw UnimplementedError(),
      _ => throw UnimplementedError(),
    };
  }
}

// -----------------
// Point features
// -----------------

class MultiPointFeature extends Feature {
  MultiPointFeature(this.points, super.attributes);

  final List<Point<int>> points;
}

class PointFeature extends MultiPointFeature {
  PointFeature(Point<int> point, Map<String, Object> attributes) : super([point], attributes);

  Point<int> get point => points.first;
}

MultiPointFeature _parsePointFeature(pb.Tile_Feature feature, Map<String, Object> attributes) {
  final geometry = parseGeometry(feature.geometry);
  assert(geometry.isNotEmpty);

  final points = <Point<int>>[];

  withCursorPoint(
    geometry,
    (command, cursorPoint) {
      assert(command is MoveToCommand);
      points.add(cursorPoint);
    },
  );

  if (points.length == 1) {
    return PointFeature(points.first, attributes);
  }

  return MultiPointFeature(points, attributes);
}

// -----------------
// LineString features
// -----------------

class LineString {
  LineString(this.points);

  final List<Point<int>> points;
}

class MultiLineStringFeature extends Feature {
  MultiLineStringFeature(this.lines, super.attributes);

  final List<LineString> lines;
}

class LineStringFeature extends MultiLineStringFeature {
  LineStringFeature(LineString line, Map<String, Object> attributes) : super([line], attributes);

  LineString get line => lines.first;
}

MultiLineStringFeature _parseLineStringFeature(pb.Tile_Feature feature, Map<String, Object> attributes) {
  final geometry = parseGeometry(feature.geometry);
  assert(geometry.isNotEmpty);

  final lines = <List<Point<int>>>[];

  withCursorPoint(
    geometry,
    (command, cursorPoint) {
      if (command is MoveToCommand) {
        lines.add([cursorPoint]);
      } else if (command is LineToCommand) {
        lines.last.add(cursorPoint);
      }
    },
  );

  if (lines.length == 1) {
    return LineStringFeature(LineString(lines.first), attributes);
  }

  return MultiLineStringFeature(lines.map(LineString.new).toList(), attributes);
}

// -----------------
// Polygon features
// -----------------

double _shoelaceFormula(List<Point<int>> points) {
  var area = 0;

  final length = points.length;
  for (var i = 0; i < length; i++) {
    final previousI = i == 0 ? length - 1 : i - 1;
    final nextI = i == length - 1 ? 0 : i + 1;

    area += points[i].y * (points[previousI].x - points[nextI].x);
  }

  return area.toDouble() / 2;
}

class Ring {
  Ring(this.points, this.isClockwise);

  final List<Point<int>> points;
  final bool isClockwise;

  bool get isExterior => isClockwise;
}

class Polygon {
  Polygon(this.exterior, this.interiors);

  final Ring exterior;
  final List<Ring> interiors;
}

class MultiPolygonFeature extends Feature {
  MultiPolygonFeature(this.polygons, super.attributes);

  final List<Polygon> polygons;
}

class PolygonFeature extends MultiPolygonFeature {
  PolygonFeature(Polygon polygon, Map<String, Object> attributes) : super([polygon], attributes);

  Polygon get polygon => polygons.first;
}

MultiPolygonFeature _parsePolygonFeature(pb.Tile_Feature feature, Map<String, Object> attributes) {
  final geometry = parseGeometry(feature.geometry);
  assert(geometry.isNotEmpty);

  final polygons = <Polygon>[];

  Ring? exteriorRing;
  final interiorRings = <Ring>[];

  final pointsBuffer = <Point<int>>[];

  withCursorPoint(
    geometry,
    (command, cursorPoint) {
      if (command is MoveToCommand) {
        pointsBuffer.add(cursorPoint);
      } else if (command is LineToCommand) {
        pointsBuffer.add(cursorPoint);
      } else if (command is ClosePathCommand) {
        final isClockwise = _shoelaceFormula(pointsBuffer) > 0;

        final ring = Ring(pointsBuffer.toList(), isClockwise);
        pointsBuffer.clear();

        if (isClockwise) {
          if (exteriorRing != null) {
            polygons.add(Polygon(exteriorRing!, interiorRings.toList()));
            interiorRings.clear();
          }

          exteriorRing = ring;
        } else {
          interiorRings.add(ring);
        }
      }
    },
  );

  if (exteriorRing != null) {
    polygons.add(Polygon(exteriorRing!, interiorRings.toList()));
  }

  if (polygons.length == 1) {
    return PolygonFeature(polygons.first, attributes);
  }

  return MultiPolygonFeature(polygons, attributes);
}
