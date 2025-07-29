import 'dart:async';

import 'package:hive_ce/hive.dart';
// ignore: implementation_imports
import 'package:hive_ce/src/hive_impl.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

/// Interface which is used to persist and retrieve state changes.
abstract class Storage {
  /// Returns value for key
  Map<String, dynamic>? read(String key);

  /// Persists key value pair
  Future<void> write(String key, Map<String, dynamic> value);

  /// Deletes key value pair
  Future<void> delete(String key);

  /// Clears all key value pairs from storage
  Future<void> clear();

  /// Close the storage instance which will free any allocated resources.
  /// A storage instance can no longer be used once it is closed.
  Future<void> close();
}

class LocalStorageDirectory {
  const LocalStorageDirectory(this.path);

  final String path;

  static const web = LocalStorageDirectory('');
}

class LocalStorage implements Storage {
  @visibleForTesting
  LocalStorage(this._box);

  static Future<LocalStorage> build({
    required LocalStorageDirectory storageDirectory,
  }) {
    return _lock.synchronized(() async {
      hive = HiveImpl();
      Box<Map<String, dynamic>> box;

      if (storageDirectory == LocalStorageDirectory.web) {
        box = await hive.openBox<Map<String, dynamic>>(
          'synced_bloc',
        );
      } else {
        hive.init(storageDirectory.path);
        box = await hive.openBox<Map<String, dynamic>>(
          'synced_bloc',
        );
      }

      return LocalStorage(box);
    });
  }

  /// Internal instance of [HiveImpl].
  /// It should only be used for testing.
  @visibleForTesting
  static late HiveInterface hive;

  static final _lock = Lock();

  final Box<Map<String, dynamic>> _box;

  @override
  Map<String, dynamic>? read(String key) => _box.isOpen ? _box.get(key) : null;

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.put(key, value));
    }
  }

  @override
  Future<void> delete(String key) async {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    }
  }

  @override
  Future<void> clear() async {
    if (_box.isOpen) {
      return _lock.synchronized(_box.clear);
    }
  }

  @override
  Future<void> close() async {
    if (_box.isOpen) {
      return _lock.synchronized(_box.close);
    }
  }
}
