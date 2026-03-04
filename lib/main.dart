import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/api/api_endpoints.dart';
import 'core/services/hive/hive_service.dart';
import 'core/services/storage/user_session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve API base URL from device (emulator vs physical)
  await ApiEndpoints.ensureBaseUrlInitialized();

  // Initialize Hive service
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  debugPrint('main: SharedPreferences initialized, keys=${prefs.getKeys().length}');

  // Create UserSessionService instance
  final userSessionService = UserSessionService(prefs: prefs);
  debugPrint('main: UserSessionService created: $userSessionService');

  runApp(
    ProviderScope(
      overrides: [
        // Provide the real SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Provide Hive service if you use it elsewhere
        hiveServiceProvider.overrideWithValue(hiveService),
        // Provide the real UserSessionService instance
        userSessionServiceProvider.overrideWithValue(userSessionService),
      ],
      child: const MyApp(),
    ),
  );
}
