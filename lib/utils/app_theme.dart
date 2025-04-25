import 'package:flutter/material.dart';

class AppTheme {
  // Explorer theme color palette - earthy, natural tones that evoke adventure
  static const Color primaryColor = Color(0xFF2E7D32);     // Forest Green
  static const Color secondaryColor = Color(0xFF795548);    // Earthy Brown
  static const Color tertiaryColor = Color(0xFF607D8B);     // Blue Grey
  
  // Background colors - natural, parchment-like textures
  static const Color backgroundColor = Color(0xFFF5F3E6);   // Parchment
  static const Color cardColor = Color(0xFFFAF7E6);        // Light Parchment
  
  // Text colors - deep, rich tones
  static const Color textPrimaryColor = Color(0xFF3E2723);  // Deep Brown
  static const Color textSecondaryColor = Color(0xFF5D4037); // Medium Brown
  
  // Accent colors for exploration theme
  static const Color accentColor = Color(0xFFFF9800);       // Adventure Orange
  static const Color highlightColor = Color(0xFFFFC107);    // Discovery Gold
  
  // Error and success colors
  static const Color errorColor = Color(0xFFBF360C);        // Danger Red
  static const Color successColor = Color(0xFF33691E);      // Forest Success

  // Light theme - Explorer/Adventure inspired
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: cardColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: secondaryColor.withOpacity(0.3), width: 1),
      ),
      margin: const EdgeInsets.all(12.0),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: secondaryColor.withOpacity(0.5),
      titleTextStyle: const TextStyle(
        fontFamily: 'Adventure',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 3,
        shadowColor: secondaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.7)),
      prefixIconColor: secondaryColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryColor,
        height: 1.5,
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
  );

  // Dark theme - Night Explorer/Adventure inspired
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      primary: const Color(0xFF81C784),         // Light Forest Green
      secondary: const Color(0xFFBCAAA4),       // Light Earthy Brown
      tertiary: const Color(0xFF90A4AE),        // Light Blue Grey
      surface: const Color(0xFF263238),         // Deep Blue-Grey
      background: const Color(0xFF1A2327),      // Dark Night Sky
      error: const Color(0xFFFF8A65),           // Soft Error Orange
      onPrimary: const Color(0xFF1A2327),       // Dark Text on Primary
      onSecondary: const Color(0xFF1A2327),     // Dark Text on Secondary
      onSurface: Colors.white,                  // White Text on Surface
      onBackground: Colors.white,               // White Text on Background
      onError: Colors.white,                    // White Text on Error
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A2327),  // Dark Night Sky
    cardTheme: CardTheme(
      color: const Color(0xFF263238),           // Deep Blue-Grey
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF455A64), width: 1),
      ),
      margin: const EdgeInsets.all(12.0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B5E20),        // Dark Forest Green
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Color(0xFF000000),
      titleTextStyle: TextStyle(
        fontFamily: 'Adventure',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),  // Forest Green
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 3,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF263238),       // Deep Blue-Grey
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF455A64)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF455A64)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Color(0xFFCFD8DC)),
      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
      prefixIconColor: const Color(0xFF90A4AE),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFECEFF1),
        height: 1.5,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF81C784),
      size: 24,
    ),
  );
}
