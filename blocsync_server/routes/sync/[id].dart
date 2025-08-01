import 'dart:io';

import 'package:blocsync_server/blocsync_server.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, id),
    HttpMethod.put => _onPut(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  final userId = context.read<UserId>();
  final storage = context.read<StateStorage>();
  String key;
  if (userId == null) {
    key = id;
  } else {
    key = '$userId:$id';
  }
  final json = await storage.get(key);
  if (json == null) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response.json(body: json);
}

Future<Response> _onPut(RequestContext context, String id) async {
  final userId = context.read<UserId>();
  final storage = context.read<StateStorage>();
  final state = await context.request.json();
  final stateJson = Map<String, dynamic>.from(state as Map);
  if (userId == null) {
    await storage.put(id, stateJson);
  } else {
    await storage.put('$userId:$id', stateJson);
  }
  return Response();
}
