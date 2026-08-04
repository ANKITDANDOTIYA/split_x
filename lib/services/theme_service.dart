import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const String boxName = 'settings_box';
  static const String themeKey = 'theme_mode';

  /// Initializes the settings Hive box
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  /// Gets stored ThemeMode preference, defaulting to ThemeMode.system
  ThemeMode getThemeMode() {
    try {
      if (!Hive.isBoxOpen(boxName)) return ThemeMode.system;
      final box = Hive.box(boxName);
      final rawValue = box.get(themeKey, defaultValue: 'system') as String;
      switch (rawValue) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      debugPrint("Error reading theme mode from Hive: $e");
      return ThemeMode.system;
    }
  }

  /// Persists selected ThemeMode preference to Hive
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
      final box = Hive.box(boxName);
      String value;
      switch (mode) {
        case ThemeMode.light:
          value = 'light';
          break;
        case ThemeMode.dark:
          value = 'dark';
          break;
        case ThemeMode.system:
          value = 'system';
          break;
      }
      await box.put(themeKey, value);
    } catch (e) {
      debugPrint("Error saving theme mode to Hive: $e");
    }
  }
}
