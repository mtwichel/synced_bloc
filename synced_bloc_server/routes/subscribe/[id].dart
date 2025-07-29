// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:broadcast_bloc/broadcast_bloc.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:state_storage/state_storage.dart';
import 'package:synced_bloc_server/src/user_middleware.dart';

class StatesBloc extends BroadcastCubit<Map<String, dynamic>?> {
  StatesBloc(this.id, this.storage) : super(null) {
    _initialize();
  }

  final StateStorage storage;

  void setState(Map<String, dynamic> stateJson) {
    emit(stateJson);
    storage.put(id, stateJson);
  }

  final String id;

  Future<void> _initialize() async {
    final state = await storage.get(id);
    if (state != null) {
      emit(state);
    }
  }
}

StatesBloc? bloc;

Future<Response> onRequest(RequestContext context, String id) async {
  final stateStorage = context.read<StateStorage>();
  final userId = context.read<UserId>();
  final key = userId == null ? id : '$userId:$id';

  bloc ??= StatesBloc(key, stateStorage);
  final handler = webSocketHandler(
    (channel, protocol) {
      print('connected');
      bloc!.subscribe(channel);
      final state = bloc!.state;
      if (state != null) {
        channel.sink.add(state);
      }
      channel.stream.listen(
        (message) {
          print('received: $message');
          if (message is! String) return;
          bloc!.setState(jsonDecode(message) as Map<String, dynamic>);
        },
        onDone: bloc?.close,
      );
    },
  );
  return handler(context);
}
