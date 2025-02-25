import 'dart:ffi';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/scheduler.dart';
import 'package:dart_earcut/dart_earcut.dart' as earcut;

import 'package:gpu_vector_tile_renderer/_vector_tile.dart' as vt;
import 'package:gpu_vector_tile_renderer/src/ffi/bindings.gen.dart';
import 'package:gpu_vector_tile_renderer/src/ffi/earcut.dart';
import 'package:gpu_vector_tile_renderer/src/isolates/isolates.dart';

class Tessellator {
  static Future<List<int>> tessellatePolygonIsolate(vt.Polygon polygon) async {
    return withZoneArena(() async {
      final polygonRef = allocPolygon(polygon);
      final resultPtr = await Isolates.instance.tesselator.execute(polygonRef);

      final result = resultPtr.ref.indices.asTypedList(resultPtr.ref.count).toList();
      free_tessellation_result(resultPtr);

      return result;
    });
  }

  static List<int> tessellatePolygon(vt.Polygon polygon) {
    final vertices = List.of(polygon.exterior.points);
    final holeIndices = <int>[];

    for (final interiorRing in polygon.interiors) {
      holeIndices.add(vertices.length);
      vertices.addAll(interiorRing.points);
    }

    return earcut.Earcut.triangulateRaw(
      List.generate(
        vertices.length * 2,
        (i) => i.isEven ? vertices.elementAt(i ~/ 2).dx : vertices.elementAt(i ~/ 2).dy,
        growable: false,
      ),
      holeIndices: holeIndices,
    );
  }

  static Future<List<int>> tessellatePolygonAsync(vt.Polygon polygon) async {
    return SchedulerBinding.instance.scheduleTask(() => tessellatePolygon(polygon), Priority.touch);
  }
}
