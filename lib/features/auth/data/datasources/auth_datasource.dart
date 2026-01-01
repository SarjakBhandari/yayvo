import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

abstract interface class IAuthDataSource {
  /// Register a new user (consumer or retailer)
  Future<AuthHiveModel> register(AuthHiveModel user);

  /// Login by email + password, restricted by userType
  Future<AuthHiveModel?> login(
      String email,
      String password,
      UserType userType,
      );

  /// Get user by ID, restricted by userType
  Future<AuthHiveModel?> getUserById(
      String authId,
      UserType userType,
      );

  /// Get user by email, restricted by userType
  Future<AuthHiveModel?> getUserByEmail(
      String email,
      UserType userType,
      );

  /// Update user details, only if userType matches
  Future<bool> updateUser(AuthHiveModel user);

  /// Delete user by ID, restricted by userType
  Future<bool> deleteUser(
      String authId,
      UserType userType,
      );

  /// Get the currently logged-in user (from session/local storage)
  Future<AuthHiveModel?> getCurrentUser();

  /// Logout the current user (clear session/local storage)
  Future<bool> logout();

  /// Get the userType for a given authId
  Future<UserType?> getUserType(String authId);
}
