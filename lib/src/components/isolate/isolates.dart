import 'package:maplibre_flutter_gpu/src/components/isolate/core/worker_isolate_pool.dart';
import 'package:maplibre_flutter_gpu/src/components/isolate/tesselator_worker_isolate.dart';

class Isolates {
  Isolates._();

  static final Isolates instance = Isolates._();

  Future<void> spawn() async {
    _tesselator = TesselatorWorkerIsolatePool(16);

    await Future.wait(pools.map((pool) => pool!.spawn()));
  }

  void close() {
    for (var pool in pools) {
      pool!.close();
    }

    _tesselator = null;
  }

  List<WorkerIsolatePool?> get pools => [
        _tesselator,
      ];

  TesselatorWorkerIsolatePool? _tesselator;

  TesselatorWorkerIsolatePool get tesselator => _tesselator!;
}
