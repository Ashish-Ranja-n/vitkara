import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<void> setJson(String key, Object value) async {
    final p = await _prefs;
    p.setString(key, jsonEncode(value));
  }

  static Future<T?> getJson<T>(String key, T Function(Object?) parser) async {
    final p = await _prefs;
    final s = p.getString(key);
    if (s == null) return null;
    try {
      final obj = jsonDecode(s);
      return parser(obj);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    final p = await _prefs;
    await p.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final p = await _prefs;
    return p.getString(key);
  }

  static Future<void> remove(String key) async {
    final p = await _prefs;
    await p.remove(key);
  }

  static Future<void> clearAll() async {
    final p = await _prefs;
    await p.clear();
  }
}
