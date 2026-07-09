import 'package:flutter/material.dart';

class AppTheme {
  // ---- Colors ----
  static Color primaryDark = Color(0xFF0A1128);
  static Color secondaryDark = Color(0xFF1B3A4B);
  static Color backgroundDark = Color(0xFF0D2137);
  static Color accent = Color(0xFF4ECDC4);
  static Color gold = Color(0xFFF4C430);
  static Color cardDark = Color(0x14FFFFFF); // 8% white

  static Color primaryLight = Color(0xFFF5F7FA);
  static Color secondaryLight = Color(0xFFE8EDF2);
  static Color backgroundLight = Color(0xFFFFFFFF);
  static Color cardLight = Color(0x0A000000); // 4% black
  static Color accentLight = Color(0xFF2A9D8F);

  // ---- Gradients ----
  static LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, secondaryDark, backgroundDark],
  );

  static LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE0F2F1), Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
  );

  // ---- Theme Data ----
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: primaryDark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: primaryLight,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
