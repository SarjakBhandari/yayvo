import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const _primaryPurple = Color(0xFF6C5CE7);
  static const _primaryPurpleDark = Color(0xFF5F4FD1);
  static const _accentBlue = Color(0xFF4A90E2);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'OpenSans',
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: _primaryPurple,

    colorScheme: const ColorScheme.light(
      primary: _primaryPurple,
      primaryContainer: Color(0xFFE8E4F8),
      secondary: _accentBlue,
      secondaryContainer: Color(0xFFE3F2FD),
      surface: Colors.white,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      background: Color(0xFFF8F9FA),
      error: Color(0xFFE74C3C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF2C3E50),
      onBackground: Color(0xFF2C3E50),
      outline: Color(0xFFE0E0E0),
    ),

    // Enhanced typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF2C3E50),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF2C3E50),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF7F8C8D),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // Modern card styling
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shadowColor: Colors.black.withOpacity(0.05),
    ),

    // Refined input styling
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: Color(0xFF7F8C8D),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: _primaryPurple,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: const Color(0xFF7F8C8D),
      suffixIconColor: const Color(0xFF7F8C8D),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
      ),
    ),

    // Enhanced button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: _primaryPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryPurple,
        side: const BorderSide(color: _primaryPurple, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFF7F8C8D),
        hoverColor: _primaryPurple.withOpacity(0.1),
      ),
    ),

    // Modern chip styling
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE8E4F8),
      labelStyle: const TextStyle(
        color: _primaryPurple,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide.none,
    ),

    // Dropdown styling
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Color(0xFF2C3E50)),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    // SnackBar styling
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C3E50),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
    ),

    // AppBar styling
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFFF8F9FA),
      foregroundColor: Color(0xFF2C3E50),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
        letterSpacing: -0.2,
      ),
    ),

    // Divider styling
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'OpenSans',
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: _primaryPurple,

    colorScheme: const ColorScheme.dark(
      primary: _primaryPurple,
      primaryContainer: Color(0xFF3A2F66),
      secondary: _accentBlue,
      secondaryContainer: Color(0xFF1E3A5F),
      surface: Color(0xFF1E1E1E),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      background: Color(0xFF121212),
      error: Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
      outline: Color(0xFF3A3A3A),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE0E0E0),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFE0E0E0),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF9E9E9E),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF2C2C2C),
          width: 1,
        ),
      ),
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shadowColor: Colors.black.withOpacity(0.3),
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: _primaryPurple,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: const Color(0xFF9E9E9E),
      suffixIconColor: const Color(0xFF9E9E9E),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: _primaryPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryPurple,
        side: const BorderSide(color: _primaryPurple, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFF9E9E9E),
        hoverColor: _primaryPurple.withOpacity(0.1),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF3A2F66),
      labelStyle: const TextStyle(
        color: Color(0xFFB8A8E8),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide.none,
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Color(0xFFE0E0E0)),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF2C2C2C)),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFE0E0E0),
      contentTextStyle: const TextStyle(color: Color(0xFF121212), fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF3A3A3A),
      thickness: 1,
      space: 1,
    ),
  );
}