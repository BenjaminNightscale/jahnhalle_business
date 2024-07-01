import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFFAFAFA),       // Background color for cards, sheets, and menus
    onSurface: Colors.black,       // Text color on background
    primary: Color(0xFF032E66),       // Primary color, used for elements needing emphasis
    onPrimary: Colors.white,          // Text color on primary elements
    secondary: Color(0xFF757575),     // Secondary color for less prominent UI elements
    onSecondary: Colors.white,        // Text color on secondary elements
    error: Colors.red,                // Color for indicating errors
    onError: Colors.white,            // Text color on error elements
    surfaceContainerHighest: Color(0xFFE0E0E0), // Alternative surface color
    onSurfaceVariant: Colors.black,   // Text color on surface variant
    tertiary: Color(0xFF00BFA5),      // Tertiary color for accenting elements
    onTertiary: Colors.white,         // Text color on tertiary elements
    outline: Colors.grey,             // Color for outlines and dividers
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black, // Text color for headings
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.grey, // Text color for body text
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    ),
    labelLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white, // Text color for labels
    ),
    labelMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);
