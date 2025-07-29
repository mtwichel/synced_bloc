/// {@template state_storage}
/// An interface for storing states on the server.
/// {@endtemplate}
abstract class StateStorage {
  /// {@macro state_storage}
  const StateStorage();

  /// Put a value in the storage.
  Future<void> put(String key, Map<String, dynamic> value);

  /// Get a value from the storage.
  Future<Map<String, dynamic>?> get(String key);

  /// Delete a value from the storage.
  Future<void> delete(String key);

  /// Clear the storage.
  Future<void> clear();
}
