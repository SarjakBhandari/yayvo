import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart'; // ✅ use the shared UserType

abstract interface class IAuthRepository {
  /// Register a new user (consumer or retailer).
  Future<Either<Failure, bool>> register(AuthEntity authEntity);

  /// Login using email + password, restricted by userType.
  Future<Either<Failure, AuthEntity>> login(
      String email,
      String password,
      UserType userType,
      );

  /// Get the currently logged-in user (from session/local storage).
  Future<Either<Failure, AuthEntity>> getCurrentUser();

  /// Logout the current user (clear session/local storage).
  Future<Either<Failure, bool>> logout();

  /// Get a user by their email and userType.
  Future<Either<Failure, AuthEntity>> getUserByEmail(
      String email,
      UserType userType,
      );

  /// Get a user by their authId and userType.
  Future<Either<Failure, AuthEntity>> getUserById(
      String authId,
      UserType userType,
      );

  /// Get the userType for a given authId.
  Future<Either<Failure, UserType>> getUserType(String authId);
}
