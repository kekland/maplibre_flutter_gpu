import 'dart:async';

import 'package:http/http.dart' as http;

const _zonedHttpClientSymbol = #_gpuVectorTile_zonedHttpClient;

http.Client get zonedHttpClient {
  return http.Client();
}

Future<T> runWithZonedHttpClient<T>(http.Client client, Future<T> Function() fn) {
  return runZoned(fn, zoneValues: {_zonedHttpClientSymbol: client});
}

Future<http.Response> zonedHttpGet(Uri uri) async {
  final response = await zonedHttpClient.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch: ${response.statusCode}');
  }

  return response;
}
