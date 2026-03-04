import 'package:flutter/material.dart';

class ConsumerTheme {
  ConsumerTheme._();

  // Light (default)
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFAFAF8);
  static const Color primaryText = Color(0xFF1A1612);
  static const Color bodyText = Color(0xFF5A4C38);
  static const Color accent = Color(0xFFC9A96E);
  static const Color accentDark = Color(0xFF8B6B3D);
  static const Color muted = Color(0xFF9C8E7A);
  static const Color border = Color(0xFFE8E4DC);
  static const Color borderLight = Color(0xFFF0EBE1);
  static const Color error = Color(0xFFC0392B);
  static const Color errorBorder = Color(0xFFFFDDD0);

  // Dark
  static const Color _darkBackground = Color(0xFF1A1612);
  static const Color _darkSurface = Color(0xFF2A2420);
  static const Color _darkPrimaryText = Color(0xFFFAFAF8);
  static const Color _darkBodyText = Color(0xFFB8A898);
  static const Color _darkMuted = Color(0xFF9C8E7A);
  static const Color _darkBorder = Color(0xFF3A2E24);
  static const Color _darkBorderLight = Color(0xFF4A3E34);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? _darkBackground : background;
  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? _darkSurface : surface;
  static Color primaryTextOf(BuildContext context) =>
      _isDark(context) ? _darkPrimaryText : primaryText;
  static Color bodyTextOf(BuildContext context) =>
      _isDark(context) ? _darkBodyText : bodyText;
  static Color mutedOf(BuildContext context) =>
      _isDark(context) ? _darkMuted : muted;
  static Color borderOf(BuildContext context) =>
      _isDark(context) ? _darkBorder : border;
  static Color borderLightOf(BuildContext context) =>
      _isDark(context) ? _darkBorderLight : borderLight;
}
