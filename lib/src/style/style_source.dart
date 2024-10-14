import 'dart:convert';
import 'dart:io';

import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:http/http.dart' as http;

/// A function that returns a style.
///
/// This function is used to create a style from different sources.
///
/// For common use cases, see:
/// - [createNetworkStyleSource]
/// - [createFileStyleSource]
/// - [createJsonStyleSource]
typedef StyleSourceFunction = Future<spec.Style> Function();

/// Creates a style source function that fetches a style from a network.
///
/// Internally, this function uses the [http] package to fetch the style. If
/// zoned HTTP client (e.g. `CronetHttpClient`) is used, the style will be
/// fetched using that.
///
/// The [uri] parameter is the URI that should return a valid JSON response
/// that conforms to the MapLibre Style Specification (version 8).
///
/// If the request returns a status code other than 200, an [HttpException] is
/// thrown.
StyleSourceFunction createNetworkStyleSource(Uri uri) {
  return () async {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return spec.Style.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException('Failed to fetch style: ${response.statusCode}');
    }
  };
}

/// Creates a style source function that reads a style from a file.
StyleSourceFunction createFileStyleSource(File file) {
  return () async {
    final content = await file.readAsString();
    return spec.Style.fromJson(jsonDecode(content));
  };
}

/// Creates a style source function that returns a style from a JSON object.
StyleSourceFunction createJsonStyleSource(Map<String, dynamic> json) {
  return () async {
    return spec.Style.fromJson(json);
  };
}
