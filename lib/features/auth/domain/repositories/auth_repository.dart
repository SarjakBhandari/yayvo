import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

abstract interface class IAuthRepository {
  /// Register a new consumer user (creates both Auth + Consumer).
  Future<Either<Failure, AuthEntity>> register(
      AuthEntity authEntity,
      ConsumerEntity consumerEntity,
      );

  /// Login using email + passwordHash, restricted by role.
  Future<Either<Failure, AuthEntity>> login(
      String email,
      String passwordHash,
      );

  /// Get the currently logged-in user.
  Future<Either<Failure, AuthEntity>> getCurrentUser();

  /// Logout the current user.
  Future<Either<Failure, bool>> logout();

  /// Get user by email.
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email);

  /// Get user by authId.
  Future<Either<Failure, AuthEntity>> getUserById(String authId);

  /// Update consumer profile.
  Future<Either<Failure, ConsumerEntity>> updateUser(
      String authId,
      ConsumerEntity consumerEntity,
      );

  /// Delete user by authId.
  Future<Either<Failure, bool>> deleteUser(String authId, UserType role);

  /// Get all consumers.
  Future<Either<Failure, List<ConsumerEntity>>> getAllUsers();
}