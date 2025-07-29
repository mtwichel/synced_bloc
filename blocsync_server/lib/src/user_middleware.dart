import 'package:dart_frog/dart_frog.dart';

/// The user ID of the authenticated user.
typedef UserId = String?;

/// Middleware to check if the user is authenticated.
Middleware userMiddleware() {
  return (handler) {
    return (context) async {
      var newContext = context;
      final authorizationHeader = context.request.headers['Authorization'];
      if (authorizationHeader == null) {
        newContext = newContext.provide<UserId>(() => null);
      } else {
        final [_, token] = authorizationHeader.split(' ');
        newContext = newContext.provide<UserId>(() => token);
      }
      return handler(newContext);
    };
  };
}
