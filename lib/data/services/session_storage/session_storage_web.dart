// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'session_storage_base.dart';

/// Browser sessionStorage implementation for Flutter Web.
/// Provides tab-scoped persistence that is automatically purged upon tab/window closure.
class WebSessionStorage implements SessionStorage {
  @override
  String? read(String key) {
    try {
      return html.window.sessionStorage[key];
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String key, String value) {
    try {
      html.window.sessionStorage[key] = value;
    } catch (_) {}
  }

  @override
  void delete(String key) {
    try {
      html.window.sessionStorage.remove(key);
    } catch (_) {}
  }

  @override
  void clear() {
    try {
      html.window.sessionStorage.clear();
    } catch (_) {}
  }
}

SessionStorage getSessionStorage() => WebSessionStorage();
