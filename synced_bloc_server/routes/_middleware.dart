import 'package:dart_frog/dart_frog.dart';
import 'package:synced_bloc_server/src/api_key_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(apiKeyMiddleware());
}
