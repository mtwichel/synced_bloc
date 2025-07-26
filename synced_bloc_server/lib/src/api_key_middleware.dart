import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Middleware to check if the API key is valid.
Middleware apiKeyMiddleware() {
  return (handler) {
    return (context) async {
      final apiKey = context.request.headers['x-api-key'];
      final expectedApiKey = Platform.environment['API_KEY'];
      if (apiKey != expectedApiKey) {
        return Response(statusCode: 401);
      }
      return handler(context);
    };
  };
}
