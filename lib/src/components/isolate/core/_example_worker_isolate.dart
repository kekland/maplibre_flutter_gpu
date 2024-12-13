import 'dart:convert';
import 'dart:isolate';

import 'package:maplibre_flutter_gpu/src/components/isolate/core/worker_isolate.dart';

class JsonParserWorkerIsolate extends WorkerIsolate<String, Object?> {
  JsonParserWorkerIsolate(super.name, super.commands, super.responses);

  static Future<JsonParserWorkerIsolate> spawn() {
    return WorkerIsolate.spawnWrapper(
      startRemoteIsolate,
      JsonParserWorkerIsolate.new,
    );
  }

  static void startRemoteIsolate(SendPort sendPort) {
    return WorkerIsolate.startRemoteIsolateWrapper(sendPort, work);
  }

  static Object? work(String arg) {
    return jsonDecode(arg) as Object?;
  }
}
