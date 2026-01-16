import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import 'package:yayvo/features/auth/data/datasources/auth_datasource.dart';
import 'package:yayvo/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:yayvo/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:yayvo/features/auth/data/models/auth_api_model.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_api_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

import '../models/user_type.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authDatasource: authLocalDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authDataSource = authDatasource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;

  // ---------- Register ----------
  @override
  Future<Either<Failure, AuthEntity>> register(
      AuthEntity authEntity,
      ConsumerEntity consumerEntity,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(authEntity);
        final registeredUser = await _authRemoteDataSource.register(apiModel);

        // also register consumer remotely
        final consumerApi = ConsumerApiModel.fromEntity(consumerEntity);
        await _authRemoteDataSource.registerConsumer(consumerApi);

        return Right(registeredUser.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? "Registration Failed",
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser =
        await _authDataSource.getUserByEmail(authEntity.email, UserType.consumer);
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
  }

  // ---------- Login ----------
  @override
  Future<Either<Failure, AuthEntity>> login(
      String email,
      String passwordHash,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, passwordHash);
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? "Login Failed",
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, passwordHash);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ---------- Get Current User ----------
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "No current user found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ---------- Logout ----------
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ---------- Get User By Email ----------
  @override
  Future<Either<Failure, AuthEntity>> getUserByEmail(String email) async {
    try {
      final model =
      await _authDataSource.getUserByEmail(email, UserType.consumer);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "User not found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ---------- Get User By ID ----------
  @override
  Future<Either<Failure, AuthEntity>> getUserById(String authId) async {
    try {
      final model =
      await _authDataSource.getUserById(authId, UserType.consumer);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "User not found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ---------- Update Consumer ----------
  @override
  Future<Either<Failure, ConsumerEntity>> updateUser(
      String authId,
      ConsumerEntity consumerEntity,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        final consumerApi = ConsumerApiModel.fromEntity(consumerEntity);
        final updated = await _authRemoteDataSource.registerConsumer(consumerApi);
        return Right(updated.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? "Update Failed",
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final consumerModel = ConsumerHiveModel.fromEntity(consumerEntity);
        await _authDataSource.registerConsumer(consumerModel); // acts as update
        return Right(consumerModel.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ---------- Delete User ----------
  @override
  Future<Either<Failure, bool>> deleteUser(String authId, UserType role) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.deleteUser(authId, role);
        return Right(result);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? "Delete Failed",
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _authDataSource.deleteUser(authId, role);
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ---------- Get All Consumers ----------
  @override
  Future<Either<Failure, List<ConsumerEntity>>> getAllUsers() async {
    if (await _networkInfo.isConnected) {
      try {
        final consumers = await _authRemoteDataSource.getAllConsumers();
        return Right(consumers.map((c) => c.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? "Fetch Failed",
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final consumers = await _authDataSource.getAllConsumers();
        return Right(consumers.map((c) => c.toEntity()).toList());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}