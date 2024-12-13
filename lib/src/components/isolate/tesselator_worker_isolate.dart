import 'dart:isolate';
import 'dart:math';

import 'package:dart_earcut/dart_earcut.dart';
import 'package:maplibre_flutter_gpu/src/components/isolate/core/worker_isolate.dart';
import 'package:maplibre_flutter_gpu/src/components/isolate/core/worker_isolate_pool.dart';

typedef _TArg = (List<Point<double>> polygonVertices, List<int>? holeIndices);
typedef _TReturn = List<int>;

class TesselatorWorkerIsolate extends WorkerIsolate<_TArg, _TReturn> {
  TesselatorWorkerIsolate(super.name, super.commands, super.responses);

  static Future<TesselatorWorkerIsolate> spawn() {
    return WorkerIsolate.spawnWrapper(
      startRemoteIsolate,
      TesselatorWorkerIsolate.new,
    );
  }

  static void startRemoteIsolate(SendPort sendPort) {
    return WorkerIsolate.startRemoteIsolateWrapper(sendPort, work);
  }

  static _TReturn work(_TArg arg) {
    return Earcut.triangulateFromPoints(arg.$1, holeIndices: arg.$2);
  }
}

class TesselatorWorkerIsolatePool extends WorkerIsolatePool<_TArg, _TReturn, TesselatorWorkerIsolate> {
  TesselatorWorkerIsolatePool(int size) : super(size, TesselatorWorkerIsolate.spawn);
}
