import 'package:blocsync_server/blocsync_server.dart';
import 'package:redis/redis.dart';

/// {@template redis_state_storage}
/// A state storage using Redis.
/// {@endtemplate}
class RedisStateStorage implements StateStorage {
  /// {@macro redis_state_storage}
  RedisStateStorage();

  late final Command _command;

  /// Initialize the Redis state storage.
  Future<void> initialize({
    required String host,
    required int port,
    String? password,
  }) async {
    final client = RedisConnection();
    _command = await client.connect(host, port);
    if (password != null) {
      await _command.send_object(['AUTH', password]);
    }
  }

  @override
  Future<void> clear() async {
    await _command.send_object(['FLUSHALL']);
  }

  @override
  Future<void> delete(String key) async {
    await _command.send_object(['DEL', key]);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final result = await _command.send_object(['GET', key]);
    return result as Map<String, dynamic>?;
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _command.send_object(['SET', key, value]);
  }
}
