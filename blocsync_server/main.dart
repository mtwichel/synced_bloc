import 'dart:async';
import 'dart:io';

import 'package:blocsync_server/blocsync_server.dart';
import 'package:dart_frog/dart_frog.dart';

late final StateStorage storage;

Future<void> init(InternetAddress ip, int port) async {
  storage = await _initializeStorage();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  return serve(handler, ip, port);
}

Future<StateStorage> _initializeStorage() async {
  final storageType = Platform.environment['STORAGE_TYPE'] ?? 'hive';
  switch (storageType) {
    case 'hive':
      final path = Platform.environment['HIVE_PATH'] ?? 'storage';
      final hiveStorage = HiveStateStorage();
      await hiveStorage.initialize(path);
      return hiveStorage;

    case 'redis':
      final host = Platform.environment['REDIS_HOST'] ?? 'localhost';
      final port = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');
      final password = Platform.environment['REDIS_PASSWORD'];

      final redisStorage = RedisStateStorage();
      await redisStorage.initialize(
        host: host,
        port: port,
        password: password,
      );
      return redisStorage;

    default:
      throw Exception('Invalid storage type: $storageType');
  }
}
