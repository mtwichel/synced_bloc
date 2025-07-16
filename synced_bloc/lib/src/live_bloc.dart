import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:synced_bloc/src/local_storage.dart';
import 'package:web_socket_client/web_socket_client.dart';

abstract class LiveBloc<Event, State> extends Bloc<Event, State> {
  LiveBloc(super.initialState) {
    init();
  }

  static Storage? _storage;

  static set storage(Storage? storage) => _storage = storage;

  static Storage get storage {
    if (_storage == null) throw Exception('Storage not found');
    return _storage!;
  }

  static bool secure = true;
  static int? port;

  static String? _serverHost;

  static set serverHost(String? serverHost) => _serverHost = serverHost;

  static String get serverHost {
    if (_serverHost == null) throw Exception('Server URL not found');
    return _serverHost!;
  }

  static http.Client client = http.Client();

  late final WebSocket socket;
  late final StreamSubscription<dynamic> subscription;

  State? _state;

  @override
  State get state => _state ?? super.state;

  void init() {
    // Fetch from local storage
    try {
      final stateJson = storage.read(storageToken) as Map<dynamic, dynamic>?;
      _state = stateJson != null
          ? fromJson(Map<String, dynamic>.from(stateJson))
          : super.state;
    } catch (error, stackTrace) {
      this.onError(error, stackTrace);
      _state = super.state;
    }

    // Fetch from remote storage
    _subscribeToRemote();
  }

  Future<void> _subscribeToRemote() async {
    final uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: serverHost,
      port: port,
      path: '/subscribe/$storageToken',
    );
    socket = WebSocket(uri);

    subscription = socket.messages.listen((message) {
      if (message is! String) return;
      final json = jsonDecode(message) as Map<String, dynamic>;
      _state = fromJson(json)!;
      // ignore: invalid_use_of_visible_for_testing_member
      emit(_state!);
    });
  }

  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    // Save to local storage
    final state = change.nextState;
    _state = state;

    try {
      final stateJson = toJson(state);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
      }
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }

    // Save to remote storage
    socket.send(jsonEncode(toJson(state)));
  }

  String get id => '';

  String get storagePrefix => runtimeType.toString();

  @nonVirtual
  String get storageToken => '$storagePrefix$id';

  State? fromJson(Map<String, dynamic> json);

  Map<String, dynamic>? toJson(State state);

  @override
  Future<void> close() async {
    subscription.cancel();
    socket.close();
    super.close();
  }
}
