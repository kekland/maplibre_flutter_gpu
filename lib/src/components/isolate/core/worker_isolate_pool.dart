import 'dart:async';

import 'package:maplibre_flutter_gpu/src/components/isolate/core/worker_isolate.dart';

class WorkerIsolatePool<TArg, TReturn, T extends WorkerIsolate<TArg, TReturn>> {
  WorkerIsolatePool(
    this.size,
    Future<T> Function() spawn,
  )   : _spawn = spawn,
        name = '${T}Pool/$size';

  final String name;
  final int size;
  final Future<T> Function() _spawn;

  final _initializationCompleter = Completer<void>();
  final _isolates = <T>[];

  Future<void> spawn() async {
    assert(size > 0);
    final isolates = await Future.wait(List.generate(size, (_) => _spawn()));

    _isolates.addAll(isolates);
    _initializationCompleter.complete();
  }

  Future<void> _initializationBlock() async {
    if (!_initializationCompleter.isCompleted) {
      await _initializationCompleter.future;
    }
  }

  T get _leastBusyIsolate {
    if (_isolates.length == 1) return _isolates.first;

    return _isolates.reduce(
      (a, b) => a.requestCount < b.requestCount ? a : b,
    );
  }

  Future<TReturn> execute(TArg arg) async {
    await _initializationBlock();
    return _leastBusyIsolate.call(arg);
  }

  void close() {
    for (final isolate in _isolates) {
      isolate.close();
    }
  }
}
