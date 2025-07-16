import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../main.dart';

Future<Response> onRequest(RequestContext context, String id) {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, id),
    HttpMethod.put => _onPut(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  final json = box.get(id);
  return Response.json(body: json);
}

Future<Response> _onPut(RequestContext context, String id) async {
  final state = await context.request.body();
  await box.put(id, state);
  return Response();
}
