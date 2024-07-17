import 'package:flutter/material.dart';
import 'dark_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkMode; // Set the default theme to dark mode

  ThemeData get themeData => _themeData;

  bool get isDarkMode => true; // Always return true for dark mode

  set themeData(ThemeData themeData) {
    // Prevent changing the theme
  }

  void toggleTheme() {
    // Prevent toggling the theme
  }
}
