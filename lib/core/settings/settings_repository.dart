import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_config.dart';

/// Persistance simple des réglages via SharedPreferences.
class SettingsRepository {
  static const _key = 'alarm_config';

  Future<AlarmConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const AlarmConfig();
    try {
      return AlarmConfig.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (_) {
      return const AlarmConfig();
    }
  }

  Future<void> save(AlarmConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config.toJson()));
  }
}
