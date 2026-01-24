import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSession {
  final String userId;
  final String email;
  final String role;

  const UserSession({
    required this.userId,
    required this.email,
    required this.role,
  });

  UserSession copyWith({
    String? userId,
    String? email,
    String? role,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_email': email,
      'user_role': role,
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      userId: map['user_id'] as String,
      email: map['user_email'] as String,
      role: map['user_role'] as String,
    );
  }
}

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  // Keys for theme and token
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAuthToken = 'auth_token';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login/register
  Future<void> saveUserSession(UserSession session) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, session.userId);
    await _prefs.setString(_keyUserEmail, session.email);
    await _prefs.setString(_keyUserRole, session.role);
  }

  // Check if user is logged in
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;

  // Get full user session object
  UserSession? getUserSession() {
    final userId = _prefs.getString(_keyUserId);
    final email = _prefs.getString(_keyUserEmail);
    final role = _prefs.getString(_keyUserRole);

    if (userId == null || email == null || role == null) {
      return null;
    }

    return UserSession(userId: userId, email: email, role: role);
  }

  // ===== Theme mode =====
  /// Save theme mode as a simple string: 'light', 'dark', or 'system'
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  /// Returns saved theme mode string or null if not set
  String? getThemeMode() => _prefs.getString(_keyThemeMode);

  // ===== Auth token =====
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  String? getAuthToken() => _prefs.getString(_keyAuthToken);

  Future<void> clearAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  // Update a single field in session (writes regardless of existing key)
  Future<void> updateField(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Delete a single field
  Future<void> deleteField(String key) async {
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
    }
  }

  // Clear user session (logout) — removes only session-related keys
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyThemeMode);
    await _prefs.remove(_keyAuthToken);
  }
}
