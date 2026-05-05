import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalBackupStore {
  static const _version = 1;
  static const _prefixes = ['profiles.', 'profile.'];

  Future<String> exportJson() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = <String, Map<String, Object?>>{};

    for (final key in prefs.getKeys().where(_isBackupKey).toList()..sort()) {
      final value = prefs.get(key);
      if (value is bool) {
        entries[key] = {'type': 'bool', 'value': value};
      } else if (value is int) {
        entries[key] = {'type': 'int', 'value': value};
      } else if (value is double) {
        entries[key] = {'type': 'double', 'value': value};
      } else if (value is String) {
        entries[key] = {'type': 'string', 'value': value};
      } else if (value is List<String>) {
        entries[key] = {'type': 'stringList', 'value': value};
      }
    }

    return const JsonEncoder.withIndent('  ').convert({
      'format': 'dactykids_local_backup',
      'version': _version,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'preferences': entries,
    });
  }

  Future<void> importJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'dactykids_local_backup' ||
        decoded['version'] != _version ||
        decoded['preferences'] is! Map<String, dynamic>) {
      throw const FormatException('Sauvegarde DactyKids invalide.');
    }

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(_isBackupKey).toList()) {
      await prefs.remove(key);
    }

    final entries = decoded['preferences'] as Map<String, dynamic>;
    for (final entry in entries.entries) {
      if (!_isBackupKey(entry.key) || entry.value is! Map<String, dynamic>) {
        continue;
      }
      final item = entry.value as Map<String, dynamic>;
      final type = item['type'];
      final value = item['value'];
      switch (type) {
        case 'bool':
          if (value is bool) {
            await prefs.setBool(entry.key, value);
          }
        case 'int':
          if (value is int) {
            await prefs.setInt(entry.key, value);
          }
        case 'double':
          if (value is num) {
            await prefs.setDouble(entry.key, value.toDouble());
          }
        case 'string':
          if (value is String) {
            await prefs.setString(entry.key, value);
          }
        case 'stringList':
          if (value is List) {
            await prefs.setStringList(
              entry.key,
              value.whereType<String>().toList(),
            );
          }
      }
    }
  }

  bool _isBackupKey(String key) {
    return _prefixes.any(key.startsWith);
  }
}
