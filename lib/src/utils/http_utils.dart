import 'package:http/http.dart' as http;

Future<http.Response> httpGet(Uri uri) async { 
  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Request failed: ${response.statusCode}');
  }

  return response;
}