import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/auth/presentation/pages/register_consumer_screen.dart';
import 'package:yayvo/features/auth/presentation/state/auth_state.dart';
import 'package:yayvo/features/auth/presentation/view_model/auth_viewmodel.dart';

// ─── Minimal fake ViewModel that skips all use-case provider deps ─────────
// Must extend AuthViewModel (not just Notifier<AuthState>) because
// authViewModelProvider is NotifierProvider<AuthViewModel, AuthState>.
class _FakeAuthViewModel extends AuthViewModel {
  final AuthState _initial;
  _FakeAuthViewModel([AuthState initial = const AuthState()])
    : _initial = initial;

  @override
  AuthState build() => _initial; // skip super.build() — late fields unused in tests
}

// ─── Helpers ──────────────────────────────────────────────────────────────
final _loadingState = AuthState(status: AuthStatus.loading);

/// Wraps [ConsumerRegistrationScreen] in a ProviderScope with all required
/// overrides, following the exact pattern of the project's existing tests.
Widget _buildWidget({
  required SharedPreferences prefs,
  required HiveService hiveService,
  required UserSessionService userSessionService,
  AuthState authState = const AuthState(),
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      hiveServiceProvider.overrideWithValue(hiveService),
      userSessionServiceProvider.overrideWithValue(userSessionService),
      authViewModelProvider.overrideWith(() => _FakeAuthViewModel(authState)),
    ],
    child: const MaterialApp(home: ConsumerRegistrationScreen()),
  );
}

void main() {
  // ─── Validator unit tests (no widget required) ───────────────────────────
  group('ConsumerRegistrationScreen — Validator Unit Tests', () {
    final emailRegex = RegExp(
      r"^(?!\.)(?!.*\.\.)[A-Za-z0-9_+'\-\.\*]+@[A-Za-z0-9][A-Za-z0-9\-]*(\.[A-Za-additional]{2,})+$",
    );

    String? emailValidator(String? value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return 'Please enter your email';
      if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
      return null;
    }

    String? passwordValidator(String? value) {
      if (value == null || value.isEmpty) return 'Please enter a password';
      if (value.length < 8) return 'Password must be at least 8 characters';
      return null;
    }

    String? confirmPasswordValidator(String? value, String password) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != password) return 'Passwords do not match';
      return null;
    }

    test('email validator — returns error for empty string', () {
      expect(emailValidator(''), 'Please enter your email');
    });

    test('email validator — returns error for missing @ symbol', () {
      expect(emailValidator('testexample.com'), 'Enter a valid email');
    });

    test('email validator — returns error for missing domain extension', () {
      expect(emailValidator('test@example'), 'Enter a valid email');
    });

    test('email validator — returns error for double consecutive dots', () {
      expect(emailValidator('test..user@example.com'), 'Enter a valid email');
    });

    test('email validator — returns null for valid email', () {
      expect(emailValidator('test@example.com'), isNull);
    });

    test('password validator — returns error for empty password', () {
      expect(passwordValidator(''), 'Please enter a password');
    });

    test('password validator — returns error for password under 8 chars', () {
      expect(
        passwordValidator('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('password validator — returns null for exactly 8 characters', () {
      expect(passwordValidator('12345678'), isNull);
    });

    test('password validator — returns null for strong password', () {
      expect(passwordValidator('MyP@ssw0rd!'), isNull);
    });

    test('confirm password validator — returns error for empty value', () {
      expect(
        confirmPasswordValidator('', 'password123'),
        'Please confirm your password',
      );
    });

    test(
      'confirm password validator — returns error when passwords differ',
      () {
        expect(
          confirmPasswordValidator('wrongpass', 'correctpass'),
          'Passwords do not match',
        );
      },
    );

    test('confirm password validator — returns null when passwords match', () {
      expect(confirmPasswordValidator('samepass', 'samepass'), isNull);
    });
  });

  // ─── Widget Tests ─────────────────────────────────────────────────────────
  group('ConsumerRegistrationScreen — Widget Tests', () {
    late SharedPreferences prefs;
    late HiveService hiveService;
    late UserSessionService userSessionService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      hiveService = HiveService();
      userSessionService = UserSessionService(prefs: prefs);
    });

    // ── Rendering ────────────────────────────────────────────────────────

    testWidgets('renders exactly 6 TextFormField widgets', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('renders "Create Consumer Account" heading', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.text('Create Consumer Account'), findsOneWidget);
    });

    testWidgets('renders Register submit button', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('renders "Already registered? Login" link', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      // The link is a RichText with two TextSpans, so find.text() won't match
      // individual spans — check the full concatenated plain text instead.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('Already registered?'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders three gender radio buttons', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.byType(Radio<String>), findsNWidgets(3));
    });

    testWidgets('renders Male, Female, Other gender labels', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('Male gender is selected by default', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      final maleRadio = tester.widget<Radio<String>>(
        find.byWidgetPredicate((w) => w is Radio<String> && w.value == 'Male'),
      );
      expect(maleRadio.groupValue, 'Male');
    });

    testWidgets('renders Country dropdown', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets(
      'renders password visibility toggle icons on both password fields',
      (tester) async {
        await tester.pumpWidget(
          _buildWidget(
            prefs: prefs,
            hiveService: hiveService,
            userSessionService: userSessionService,
          ),
        );
        // Both password fields start with visibility_off
        expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      },
    );

    testWidgets('shows "Registering..." on Register button while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
          authState: _loadingState,
        ),
      );
      await tester.pump();
      expect(find.text('Registering...'), findsOneWidget);
      expect(find.text('Register'), findsNothing);
    });

    // ── Interaction — gender radio ─────────────────────────────────────────

    testWidgets('tapping Female radio changes selection', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Radio<String> && w.value == 'Female',
        ),
      );
      await tester.pump();
      final femaleRadio = tester.widget<Radio<String>>(
        find.byWidgetPredicate(
          (w) => w is Radio<String> && w.value == 'Female',
        ),
      );
      expect(femaleRadio.groupValue, 'Female');
    });

    testWidgets('tapping Other radio changes selection', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.tap(
        find.byWidgetPredicate((w) => w is Radio<String> && w.value == 'Other'),
      );
      await tester.pump();
      final otherRadio = tester.widget<Radio<String>>(
        find.byWidgetPredicate((w) => w is Radio<String> && w.value == 'Other'),
      );
      expect(otherRadio.groupValue, 'Other');
    });

    // ── Interaction — password visibility toggle ───────────────────────────

    testWidgets('tapping eye icon on Password field toggles to visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets(
      'tapping eye icon on Confirm Password field toggles to visible',
      (tester) async {
        await tester.pumpWidget(
          _buildWidget(
            prefs: prefs,
            hiveService: hiveService,
            userSessionService: userSessionService,
          ),
        );
        // Scroll confirm password eye icon into view before tapping
        await tester.ensureVisible(find.byIcon(Icons.visibility_off).last);
        await tester.tap(find.byIcon(Icons.visibility_off).last);
        await tester.pump();
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );

    // ── Form validation — submit with empty fields ─────────────────────────

    testWidgets('shows name required error on empty submit', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('shows email required error on empty submit', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad email format', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows phone required error on empty submit', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter phone'), findsOneWidget);
    });

    testWidgets('shows password required error on empty submit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9800000000');
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('shows short password error when password is under 8 chars', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(4), 'short');
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows confirm password required error on empty confirm', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      // Index 5 (confirm) intentionally left empty
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows passwords do not match error when confirm differs', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'different456');
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows country required error when dropdown not selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(3), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'password123');
      // Country not selected
      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      expect(find.text('Please select your country'), findsOneWidget);
    });

    // ── Navigation ────────────────────────────────────────────────────────

    testWidgets('tapping Login link navigates to LoginScreen', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      // The link is a RichText inside a GestureDetector — tap via predicate
      final loginRichText = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Login'),
      );
      await tester.ensureVisible(loginRichText);
      await tester.tap(loginRichText);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    // ── Scaffolding / layout ──────────────────────────────────────────────

    testWidgets('Scaffold has resizeToAvoidBottomInset set to false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.resizeToAvoidBottomInset, isFalse);
    });

    testWidgets('body is wrapped in SingleChildScrollView', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
      'empty form submit stays on registration screen (no navigation)',
      (tester) async {
        await tester.pumpWidget(
          _buildWidget(
            prefs: prefs,
            hiveService: hiveService,
            userSessionService: userSessionService,
          ),
        );
        await tester.ensureVisible(find.text('Register'));
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle();
        expect(find.byType(ConsumerRegistrationScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets('Date of Birth field is wrapped in AbsorbPointer (read-only)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      // Check that the absorbing AbsorbPointer (DOB read-only wrapper) exists
      expect(
        find.byWidgetPredicate(
          (w) => w is AbsorbPointer && w.absorbing == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('entering text in Full Name field updates displayed value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('entering text in Email field updates displayed value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.pump();
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      // EditableText (inside TextField inside TextFormField) exposes obscureText
      final editables = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(editables[4].obscureText, isTrue);
    });

    testWidgets('confirm password field is obscured by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWidget(
          prefs: prefs,
          hiveService: hiveService,
          userSessionService: userSessionService,
        ),
      );
      final editables = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(editables[5].obscureText, isTrue);
    });
  });
}
