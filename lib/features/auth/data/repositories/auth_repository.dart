import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/features/auth/data/datasources/auth_datasource.dart';
import 'package:yayvo/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepositoryImpl(authDatasource: authDatasource);
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;

  AuthRepositoryImpl({required IAuthLocalDataSource authDatasource})
      : _authDataSource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> register(
      AuthEntity authEntity,
      ConsumerEntity consumerEntity,
      ) async {
    try {
      final existingUser = await _authDataSource.getUserByEmail(
        authEntity.email,
        UserType.consumer,
      );
      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(message: "Email already registered"),
        );
      }

      final authModel = AuthHiveModel.fromEntity(authEntity);
      await _authDataSource.register(authModel);

      final consumerModel = ConsumerHiveModel.fromEntity(consumerEntity);
      await _authDataSource.registerConsumer(consumerModel);

      return Right(authModel.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email,
      String passwordHash,
      ) async {
    try {
      // Data source no longer needs role passed in
      final model = await _authDataSource.login(email, passwordHash);

      if (model != null) {
        // model.toEntity() should already include the role field
        return Right(model.toEntity());
      }

      return const Left(
        LocalDatabaseFailure(message: "Invalid email or password"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: "No current user found"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email) async {
    try {
      final model = await _authDataSource.getUserByEmail(email, UserType.consumer);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: "User not found"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getUserById(String authId) async {
    try {
      final model = await _authDataSource.getUserById(authId, UserType.consumer);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: "User not found"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConsumerEntity>> updateUser(
      String authId,
      ConsumerEntity consumerEntity,
      ) async {
    try {
      // Re-register consumer to update profile
      final consumerModel = ConsumerHiveModel.fromEntity(consumerEntity);
      await _authDataSource.registerConsumer(consumerModel);

      return Right(consumerModel.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String authId, UserType role) async {
    try {
      final result = await _authDataSource.deleteUser(authId, role);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // 👇 This was missing
  @override
  Future<Either<Failure, List<ConsumerEntity>>> getAllUsers() async {
    try {
      final consumers = await _authDataSource.getAllConsumers();
      return Right(consumers.map((c) => c.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}