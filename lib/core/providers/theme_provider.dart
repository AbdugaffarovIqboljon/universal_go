import 'package:flutter/material.dart';
import 'package:universal_go/core/services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeMode defaultThemeMode = ThemeMode.light})
      : _themeMode = defaultThemeMode,
        _defaultThemeMode = defaultThemeMode;

  ThemeMode _themeMode;
  final ThemeMode _defaultThemeMode;
  
  ThemeMode get themeMode => _themeMode;
  
  /// Initialize theme from SharedPreferences, fallback to default
  Future<void> initializeTheme() async {
    _themeMode = await ThemeService.getThemeMode(defaultMode: _defaultThemeMode);
    notifyListeners();
  }
  
  /// Change theme mode and save to SharedPreferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await ThemeService.setThemeMode(themeMode);
    notifyListeners();
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  /// Get current theme mode as string
  String get themeModeString => ThemeService.getThemeModeString(_themeMode);
  
  /// Get current theme mode description
  String get themeModeDescription => ThemeService.getThemeModeDescription(_themeMode);
  
  /// Check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Check if current theme is light
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  /// Check if current theme follows system
  bool get isSystemMode => _themeMode == ThemeMode.system;
}