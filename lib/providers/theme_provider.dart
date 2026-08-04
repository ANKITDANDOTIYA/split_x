import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System Default";
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Loads saved theme mode from ThemeService
  void _loadThemeMode() {
    _themeMode = _themeService.getThemeMode();
    notifyListeners();
  }

  /// Updates active theme mode, persists preference, and notifies app listeners
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _themeService.saveThemeMode(mode);
  }
}
