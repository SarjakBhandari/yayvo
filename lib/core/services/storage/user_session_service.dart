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
    String? role

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
      'user_role': role
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

    return UserSession(
      userId: userId,
      email: email,
      role: role
    );
  }


  // Update a single field in session
  Future<void> updateField(String key, String value) async {
    if (_prefs.containsKey(key)) {
      await _prefs.setString(key, value);
    }
  }

  // Delete a single field
  Future<void> deleteField(String key) async {
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
    }
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.clear();
  }
}