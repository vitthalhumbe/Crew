import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? mode = prefs.getString("app_theme");

    if (mode == "light") {
      _themeMode = ThemeMode.light;
    } else if (mode == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  // Change theme
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mode == ThemeMode.light) {
      prefs.setString("app_theme", "light");
    } else if (mode == ThemeMode.dark) {
      prefs.setString("app_theme", "dark");
    } else {
      prefs.setString("app_theme", "system");
    }
  }
}
