import 'session_storage_base.dart';

/// In-memory session storage implementation for VM, unit test, and non-web environments.
class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _data = {};

  @override
  String? read(String key) => _data[key];

  @override
  void write(String key, String value) {
    _data[key] = value;
  }

  @override
  void delete(String key) {
    _data.remove(key);
  }

  @override
  void clear() {
    _data.clear();
  }
}

SessionStorage getSessionStorage() => InMemorySessionStorage();
