import 'package:blocsync_server/src/api_key_middleware.dart';
import 'package:blocsync_server/src/user_middleware.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:state_storage/state_storage.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(apiKeyMiddleware())
      .use(userMiddleware())
      .use(provider<StateStorage>((_) => storage));
}
