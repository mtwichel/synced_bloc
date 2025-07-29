import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_client/web_socket_client.dart';

class ApiClient {
  ApiClient({
    required this.apiKey,
    required Uri baseUrl,
    http.Client? client,
    this.authenticationToken,
  }) : client = client ?? http.Client(),
       host = baseUrl.host,
       port = baseUrl.port,
       secure = baseUrl.scheme.endsWith('s');

  final String apiKey;
  final http.Client client;

  final String host;
  final int port;
  final bool secure;

  String? authenticationToken;

  Uri _makeUrl(
    String path, {
    String scheme = 'http',
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: secure ? '${scheme}s' : scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetch(
    String storageToken, {
    required bool isPrivate,
  }) async {
    if (isPrivate && authenticationToken == null) {
      throw Exception('Authentication token is required for private data');
    }

    final response = await client.get(
      _makeUrl('/sync/$storageToken'),
      headers: {
        'x-api-key': apiKey,
        if (isPrivate && authenticationToken != null)
          'x-authentication-token': authenticationToken!,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch data from server');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  Future<void> save(
    String storageToken, {
    required Map<String, dynamic> data,
    required bool isPrivate,
  }) async {
    if (isPrivate && authenticationToken == null) {
      throw Exception('Authentication token is required for private data');
    }

    final response = await client.put(
      _makeUrl('/sync/$storageToken'),
      headers: {
        'x-modified-at': DateTime.now().toIso8601String(),
        'x-api-key': apiKey,
        if (isPrivate && authenticationToken != null)
          'x-authentication-token': authenticationToken!,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save data to server');
    }
  }

  WebSocket connect(String storageToken) {
    final uri = _makeUrl('/subscribe/$storageToken', scheme: 'ws');

    return WebSocket(uri, headers: {'x-api-key': apiKey});
  }
}
