import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: const ColorScheme.dark(
    background: Colors.black, // Primary background color for dark theme
    surface: Color(0xFF333333), // Background color for cards, sheets, and menus
    onBackground: Colors.white, // Text color on background
    primary:
        Color(0xFF032E66), // Primary color, used for elements needing emphasis
    onPrimary: Colors.black, // Text color on primary elements
    secondary:
        Color(0xFFBDBDBD), // Secondary color for less prominent UI elements
    onSecondary: Colors.black, // Text color on secondary elements
    error: Colors.redAccent, // Color for indicating errors
    onError: Colors.white, // Text color on error elements
    surfaceVariant: Color(0xFF484848), // Alternative surface color
    onSurfaceVariant: Colors.white, // Text color on surface variant
    tertiary: Colors.grey, // Tertiary color for accenting elements
    onTertiary: Colors.black, // Text color on tertiary elements
    outline: Colors.blueGrey, // Color for outlines and dividers
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
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
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
);
