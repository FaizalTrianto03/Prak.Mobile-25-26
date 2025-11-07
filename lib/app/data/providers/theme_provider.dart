import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends GetxController {
  static const String _themeKey = 'isDarkTheme';
  
  final RxBool _isDarkMode = false.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  
  // Initialize and load theme (can be awaited)
  Future<void> init() async {
    await _loadTheme();
  }
  
  // Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _isDarkMode.value = isDark;
      if (kDebugMode) {
        debugPrint('Theme loaded: ${isDark ? "Dark" : "Light"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading theme: $e');
      }
      _isDarkMode.value = false; // Default to light theme
    }
  }
  
  // Toggle theme and save to SharedPreferences
  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode.value = !_isDarkMode.value;
      await prefs.setBool(_themeKey, _isDarkMode.value);
      if (kDebugMode) {
        debugPrint('Theme toggled to: ${_isDarkMode.value ? "Dark" : "Light"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving theme: $e');
      }
    }
  }
  
  // Set theme directly
  Future<void> setTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode.value = isDark;
      await prefs.setBool(_themeKey, isDark);
      if (kDebugMode) {
        debugPrint('Theme set to: ${isDark ? "Dark" : "Light"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting theme: $e');
      }
    }
  }
}

