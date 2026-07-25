import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for session, cache, and favorites.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];

  Future<void> setJson(String key, Object value) =>
      _prefs.setString(key, jsonEncode(value));

  dynamic getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> remove(String key) => _prefs.remove(key);

  bool containsKey(String key) => _prefs.containsKey(key);
}
