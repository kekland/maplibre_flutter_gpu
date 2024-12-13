import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

final _isolateCountMap = <String, int>{};

int _getIsolateIndex(String typeName) {
  final index = _isolateCountMap[typeName] ?? 0;
  _isolateCountMap[typeName] = index + 1;

  return index;
}

/// A Worker isolate has a single method to invoke on the isolate.
abstract class WorkerIsolate<TArg, TReturn> {
  WorkerIsolate(this.name, this._commands, this._responses) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  final String name;
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<TReturn>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  // --- Main isolate ---
  Future<TReturn> call(TArg message) => invokeOnIsolate(message);

  @protected
  Future<TReturn> invokeOnIsolate(TArg message) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<TReturn>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, message));

    return await completer.future;
  }

  int get requestCount => _activeRequests.length;
  bool get isBusy => requestCount > 0;

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response as TReturn);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');

      if (_activeRequests.isEmpty) _responses.close();
    }
  }

  static Future<T> spawnWrapper<T extends WorkerIsolate>(
    void Function(SendPort message) entryPoint,
    T Function(String, SendPort, ReceivePort) createWorker,
  ) async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();

    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    final typeName = T.toString();
    final index = _getIsolateIndex(typeName);

    final isolateName = '$typeName-$index';

    // Spawn the isolate.
    try {
      await Isolate.spawn(
        entryPoint,
        initPort.sendPort,
        debugName: isolateName,
      );
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return createWorker(isolateName, sendPort, receivePort);
  }

  // --- Isolate ---

  static void handleCommandsToIsolateWrapper<TArg, TReturn>(
    ReceivePort receivePort,
    SendPort sendPort,
    TReturn Function(TArg arg) work,
  ) {
    receivePort.listen((message) {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (int id, TArg arg) = message as (int, TArg);
      try {
        final result = work(arg);
        sendPort.send((id, result));
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  static void startRemoteIsolateWrapper<TArg, TReturn>(
    SendPort sendPort,
    TReturn Function(TArg arg) work,
  ) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    handleCommandsToIsolateWrapper(receivePort, sendPort, work);
  }
}
