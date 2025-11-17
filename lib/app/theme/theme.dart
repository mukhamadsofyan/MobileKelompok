import 'package:flutter/material.dart';

class AppTheme {
  // =============================================
  //  MATERIAL 3 COLOR SCHEME — CUSTOM TEAL
  // =============================================

  static const _primaryTeal = Color(0xFF009688);
  static const _secondaryTeal = Color(0xFF4DB6AC);
  static const _tertiaryTeal = Color(0xFF80CBC4);

  // ---------- LIGHT THEME ----------
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primaryTeal,
      onPrimary: Colors.white,
      secondary: _secondaryTeal,
      onSecondary: Colors.white,
      tertiary: _tertiaryTeal,
      onTertiary: Colors.black87,
      error: Colors.red,
      onError: Colors.white,
      background: Color(0xFFF8FAF9),
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),

    scaffoldBackgroundColor: const Color(0xFFF8FAF9),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: _primaryTeal,
      foregroundColor: Colors.white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primaryTeal,
      unselectedItemColor: Colors.black45,
      showUnselectedLabels: true,
    ),

    cardColor: Colors.white,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      bodyLarge: TextStyle(color: Colors.black87),
    ),
  );

  // ---------- DARK THEME ----------
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryTeal,
      onPrimary: Colors.black,
      secondary: _secondaryTeal,
      onSecondary: Colors.black,
      tertiary: _tertiaryTeal,
      onTertiary: Colors.black,
      error: Colors.red,
      onError: Colors.black,
      background: Color(0xFF0E1414),
      onBackground: Colors.white,
      surface: Color(0xFF1A2222),
      onSurface: Colors.white70,
    ),

    scaffoldBackgroundColor: const Color(0xFF0E1414),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: _primaryTeal,
      foregroundColor: Colors.white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A2222),
      selectedItemColor: _secondaryTeal,
      unselectedItemColor: Colors.white70,
      showUnselectedLabels: true,
    ),

    cardColor: const Color(0xFF1F2A2A),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );
}
