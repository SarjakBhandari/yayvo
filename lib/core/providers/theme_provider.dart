// core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';

/// Theme mode provider (uses UserSessionService for persistence)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Read persisted theme from UserSessionService synchronously
    final session = ref.read(userSessionServiceProvider);
    final saved = session.getThemeMode();
    if (saved != null) return _themeModeFromString(saved);
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final session = ref.read(userSessionServiceProvider);
    state = mode;
    await session.saveThemeMode(_themeModeToString(mode));
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
