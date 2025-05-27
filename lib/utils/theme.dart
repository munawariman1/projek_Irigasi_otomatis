import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primaryColor: const Color(0xFF2E7D32), // Green 800
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2E7D32), // Green 800
      onPrimary: Colors.white,
      secondary: Color(0xFF1B5E20), // Green 900
      onSecondary: Colors.white,
      error: Color(0xFFD32F2F), // Red 700
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2E7D32),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerColor: Colors.grey[300],
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
    ),
  );
}
