import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hive_ce/hive.dart';

late final Box<String> box;

Future<void> init(InternetAddress ip, int port) async {
  Hive.init('${Directory.current.path}/storage');
  box = await Hive.openBox<String>('storage');
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  return serve(handler, ip, port);
}
