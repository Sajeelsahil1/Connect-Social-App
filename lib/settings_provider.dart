import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // --- Theme ---
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Tell the app to rebuild
  }

  // --- View Type ---
  bool _isGridView = false; // Default to list view
  bool get isGridView => _isGridView;

  void toggleGridView() {
    _isGridView = !_isGridView;
    notifyListeners(); // Tell the app to rebuild
  }
}
