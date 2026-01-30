import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group("LoginScreen Unit Tests (validators)", () {
    test("email validator returns error for empty email", () {
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      }

      expect(validator(""), "Please enter your email");
    });

    test("email validator returns error for invalid email", () {
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      }

      expect(validator("invalidEmail"), "Enter a valid email");
    });

    test("password validator returns error for short password", () {
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      }

      expect(validator("123"), "Password must be at least 6 characters");
    });

    test("valid email and password pass", () {
      String? emailValidator(String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      }

      String? passwordValidator(String? value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      }

      expect(emailValidator("test@test.com"), null);
      expect(passwordValidator("123456"), null);
    });
  });

  group("LoginScreen Widget Tests", () {
    late SharedPreferences prefs;
    late HiveService hiveService;
    late UserSessionService userSessionService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      hiveService = HiveService();
      userSessionService = UserSessionService(prefs: prefs);
    });

    testWidgets("renders email and password fields", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(tester.widgetList(find.byType(TextFormField)).length, 2);
    });

    testWidgets("renders Sign In button", (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect((tester.widget(find.text("Sign In")) as Text).data!, "Sign In");
    });

    testWidgets("shows validation error for empty email", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.tap(find.text("Sign In"));
      await tester.pump();

      expect(
        (tester.widget(find.text("Please enter your email")) as Text).data!,
        "Please enter your email",
      );
    });

    testWidgets("shows validation error for short password", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            hiveServiceProvider.overrideWithValue(hiveService),
            userSessionServiceProvider.overrideWithValue(userSessionService),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, "test@test.com");
      await tester.enterText(find.byType(TextFormField).last, "123");
      await tester.tap(find.text("Sign In"));
      await tester.pump();

      expect(
        (tester.widget(find.text("Password must be at least 6 characters"))
                as Text)
            .data!,
        "Password must be at least 6 characters",
      );
    });
  });
}
