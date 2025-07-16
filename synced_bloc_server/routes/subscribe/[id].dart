// ignore_for_file: avoid_print

import 'package:broadcast_bloc/broadcast_bloc.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

import '../../main.dart';

class StatesBloc extends BroadcastCubit<String?> {
  StatesBloc(this.id) : super(box.get(id));

  void setState(String state) {
    emit(state);
    box.put(id, state);
  }

  final String id;
}

StatesBloc? bloc;

Future<Response> onRequest(RequestContext context, String id) async {
  bloc ??= StatesBloc(id);
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
          bloc!.setState(message);
        },
        onDone: () => print('disconnected'),
      );
    },
  );
  return handler(context);
}
