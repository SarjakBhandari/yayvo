import 'package:flutter/material.dart';

class AppTheme {
  static const Color _backgroundColor = Color(0xFFF5F0E8);
  static const Color _surfaceColor = Color(0xFFFAFAF8);
  static const Color _primaryTextColor = Color(0xFF1A1612);
  static const Color _bodyTextColor = Color(0xFF5A4C38);
  static const Color _accentColor = Color(0xFFC9A96E);
  static const Color _errorColor = Color(0xFFC0392B);
  static const Color _borderColor = Color(0xFFE8E4DC);

  static const String _bodyFont = "OpenSans";
  static const String _headingFont = "OpenSans";


  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _surfaceColor,
      dividerColor: _borderColor,
      hintColor: _bodyTextColor,
      fontFamily: _bodyFont,
      textTheme:  TextTheme(
        displayLarge: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(fontFamily: _headingFont, color: _primaryTextColor, fontWeight: FontWeight.bold),

        bodyLarge: const TextStyle(color: _bodyTextColor, ),
        bodyMedium: const TextStyle(color: _bodyTextColor),
      ),
      colorScheme: const ColorScheme.light(
        primary: _accentColor,
        secondary: _accentColor,
        surface: _surfaceColor,
        background: _backgroundColor,
        error: _errorColor,
        onPrimary: _surfaceColor,
        onSecondary: _surfaceColor,
        onSurface: _primaryTextColor,
        onBackground: _primaryTextColor,
        onError: _surfaceColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _primaryTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryTextColor,
          foregroundColor: _surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: _surfaceColor,
          foregroundColor: _bodyTextColor,
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor),
        ),
        labelStyle: const TextStyle(color: _bodyTextColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryTextColor),
        titleTextStyle: TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: const Color(0xFF1A1612),
      cardColor: const Color(0xFF2A2420),
      dividerColor: const Color(0xFF3A2E24),
      hintColor: const Color(0xFF9C8E7A),
      fontFamily: _bodyFont,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: _headingFont, color: _surfaceColor, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFFB8A898)),
        bodyMedium: TextStyle(color: Color(0xFF9C8E7A)),
      ),
      colorScheme: const ColorScheme.dark(
        primary: _accentColor,
        secondary: _accentColor,
        surface: Color(0xFF2A2420),
        background: Color(0xFF1A1612),
        error: _errorColor,
        onPrimary: _primaryTextColor,
        onSecondary: _primaryTextColor,
        onSurface: _surfaceColor,
        onBackground: _surfaceColor,
        onError: _primaryTextColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _surfaceColor,
          foregroundColor: _primaryTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2420),
          foregroundColor: const Color(0xFFB8A898),
          side: const BorderSide(color: Color(0xFF3A2E24)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2420),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A2E24)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A2E24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9C8E7A)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2A2420),
        elevation: 0,
        iconTheme: IconThemeData(color: _surfaceColor),
        titleTextStyle: TextStyle(
          fontFamily: _headingFont,
          color: _surfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
