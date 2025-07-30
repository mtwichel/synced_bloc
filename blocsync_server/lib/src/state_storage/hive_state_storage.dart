import 'package:blocsync_server/blocsync_server.dart';
import 'package:hive_ce/hive.dart';

/// {@template hive_state_storage}
/// A state storage using Hive.
/// {@endtemplate}
class HiveStateStorage implements StateStorage {
  /// {@macro hive_state_storage}
  HiveStateStorage();

  late final Box<Map<dynamic, dynamic>> _box;

  /// Initialize the Hive state storage.
  Future<void> initialize(String path) async {
    Hive.init(path);
    _box = await Hive.openBox<Map<dynamic, dynamic>>(path);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    return _box.get(key)?.cast<String, dynamic>();
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }
}
