import 'dart:io';

import 'package:blocsync_server/blocsync_server.dart';
import 'package:dart_frog/dart_frog.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  final authenticationEnabled =
      Platform.environment['AUTHENTICATION_ENABLED'] == 'true';
  var newHandler = handler
      .use(requestLogger())
      .use(apiKeyMiddleware())
      .use(provider<StateStorage>((_) => storage));

  if (authenticationEnabled) {
    newHandler = newHandler.use(jwtMiddleware());
  }

  return newHandler;
}
