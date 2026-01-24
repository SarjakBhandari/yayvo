import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/hive/hive_service.dart';
import 'core/services/storage/user_session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive service
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override providers with actual instances
        sharedPreferencesProvider.overrideWithValue(prefs),
        hiveServiceProvider.overrideWithValue(hiveService),
        // If you have a userSessionServiceProvider, you can override it here too
        // userSessionServiceProvider.overrideWithValue(UserSessionService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}