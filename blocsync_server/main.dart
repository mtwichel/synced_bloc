import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hive_state_storage/hive_state_storage.dart';
import 'package:path/path.dart' as p;
import 'package:redis_state_storage/redis_state_storage.dart';
import 'package:state_storage/state_storage.dart';

late final StateStorage storage;

Future<void> init(InternetAddress ip, int port) async {
  storage = await _initializeStorage();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  return serve(handler, ip, port);
}

Future<StateStorage> _initializeStorage() async {
  final StateStorage answer;
  final storageType = Platform.environment['STORAGE_TYPE'] ?? 'hive';
  switch (storageType) {
    case 'hive':
      final path = Platform.environment['HIVE_PATH'] ?? 'storage';
      final hiveStoragePath = p.join(Directory.current.path, path);
      final hiveStorage = HiveStateStorage(path: hiveStoragePath);
      await hiveStorage.initialize(hiveStoragePath);
      answer = hiveStorage;

    case 'redis':
      final host = Platform.environment['REDIS_HOST'] ?? 'localhost';
      final port = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');
      final password = Platform.environment['REDIS_PASSWORD'];

      final redisStorage =
          RedisStateStorage(host: host, port: port, password: password);
      await redisStorage.initialize(host, port, password);
      answer = redisStorage;

    default:
      throw Exception('Invalid storage type: $storageType');
  }
  return answer;
}
