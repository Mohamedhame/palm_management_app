import "package:flutter/material.dart";

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: const Color(0xFF2E7D32), // أخضر النخيل
    onPrimary: Colors.white,

    secondary: const Color(0xFFC49A2C), // ذهبي التمور
    onSecondary: Colors.white,

    tertiary: const Color(0xFF8D6E63), // بني التربة

    error: Colors.red,
    onError: Colors.white,

    surface: const Color(0xFFF8F5F0), // بيج فاتح
    onSurface: const Color(0xFF1E1E1E),

    primaryContainer: const Color(0xFFC8E6C9),
    onPrimaryContainer: const Color(0xFF1B5E20),

    secondaryContainer: const Color(0xFFFFECB3),
    onSecondaryContainer: const Color(0xFF5D4037),
  ),

  scaffoldBackgroundColor: const Color(0xFFF8F5F0),

  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFF2E7D32),
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size(double.infinity, 50),
    ),
  ),
);
