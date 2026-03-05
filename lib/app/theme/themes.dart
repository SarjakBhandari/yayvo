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
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          fontFamily: _headingFont,
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: _bodyTextColor),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: _primaryTextColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: _primaryTextColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: _surfaceColor,
          foregroundColor: _bodyTextColor,
          side: const BorderSide(color: _borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: _bodyTextColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9C8E7A),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
    const darkBackgroundColor = Color(0xFF1A1612);
    const darkSurfaceColor = Color(0xFF2A2420);
    const darkBorderColor = Color(0xFF3A2E24);
    const darkPrimaryTextColor = Color(0xFFFAFAF8);
    const darkBodyTextColor = Color(0xFFB8A898);
    const darkHintTextColor = Color(0xFF9C8E7A);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkSurfaceColor,
      dividerColor: darkBorderColor,
      hintColor: darkHintTextColor,
      fontFamily: _bodyFont,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: darkBodyTextColor),
        bodyMedium: TextStyle(color: darkBodyTextColor),
      ),
      colorScheme: const ColorScheme.dark(
        primary: _accentColor,
        secondary: _accentColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        error: _errorColor,
        onPrimary: _primaryTextColor,
        onSecondary: _primaryTextColor,
        onSurface: darkPrimaryTextColor,
        onBackground: darkPrimaryTextColor,
        onError: darkPrimaryTextColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: _primaryTextColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: _primaryTextColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: darkSurfaceColor,
          foregroundColor: darkBodyTextColor,
          side: const BorderSide(color: darkBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkBodyTextColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: darkHintTextColor,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkPrimaryTextColor),
        titleTextStyle: TextStyle(
          fontFamily: _headingFont,
          color: darkPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class ConsumerTheme {
  final BuildContext context;
  ConsumerTheme.of(this.context);

  ThemeData get theme => Theme.of(context);
  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get surfaceColor => theme.cardColor;
  Color get primaryTextColor =>
      isDarkMode ? const Color(0xFFFAFAF8) : const Color(0xFF1A1612);
  Color get bodyTextColor =>
      isDarkMode ? const Color(0xFFB8A898) : const Color(0xFF5A4C38);
  Color get accentColor => theme.primaryColor;
  Color get errorColor => theme.colorScheme.error;
  Color get borderColor => theme.dividerColor;
  Color get hintColor => theme.hintColor;
}
