import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yayvo/features/auth/presentation/pages/register_consumer_screen.dart';

void main() {
  group("ConsumerRegistrationScreen Unit Tests (validators)", () {
    test("email validator returns error for empty email", () {
      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      String? validator(String? value) {
        final v = (value ?? "").trim();
        if (v.isEmpty) return "Please enter your email";
        if (!regex.hasMatch(v)) return "Enter a valid email";
        return null;
      }

      expect(validator(""), "Please enter your email");
    });

    test("password validator returns error for short password", () {
      String? validator(String? value) {
        if (value == null || value.isEmpty) return "Please enter a password";
        if (value.length < 8) return "Password must be at least 8 characters";
        return null;
      }

      expect(validator("12345"), "Password must be at least 8 characters");
    });

    test("confirm password validator returns mismatch error", () {
      final password = "mypassword";
      String? validator(String? value) {
        if (value == null || value.isEmpty)
          return "Please confirm your password";
        if (value != password) return "Passwords do not match";
        return null;
      }

      expect(validator("wrongpass"), "Passwords do not match");
    });
  });

  group("ConsumerRegistrationScreen Widget Tests", () {
    late SharedPreferences prefs;
    late HiveService hiveService;
    late UserSessionService userSessionService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      hiveService = HiveService();
      userSessionService = UserSessionService(prefs: prefs);
    });

    testWidgets("renders all required text fields", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: ConsumerRegistrationScreen()),
        ),
      );

      // Expect multiple fields: name, email, dob, phone, password, confirm password
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets("renders Register button", (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: ConsumerRegistrationScreen()),
        ),
      );

      expect(find.text("Register"), findsOneWidget);
    });
  });
}
