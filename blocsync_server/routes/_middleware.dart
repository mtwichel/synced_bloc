import 'package:blocsync_server/blocsync_server.dart';
import 'package:dart_frog/dart_frog.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(apiKeyMiddleware())
      .use(jwtMiddleware())
      .use(provider<StateStorage>((_) => storage));
}
