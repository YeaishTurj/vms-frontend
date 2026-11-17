/// Abstract contract for session persistence across web and mobile/test environments.
abstract class SessionStorage {
  /// Reads a stored string value for the given key.
  String? read(String key);

  /// Stores a string value for the given key.
  void write(String key, String value);

  /// Removes a stored key-value pair.
  void delete(String key);

  /// Clears all keys managed by this storage.
  void clear();
}
