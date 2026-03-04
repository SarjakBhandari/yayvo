import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:yayvo/core/error/failures.dart';
import '../../domain/entities/consumer_entity.dart';
import '../../domain/repositories/i_consumer_repository.dart';
import '../datasources/remote/consumer_remote_datasource.dart';
import '../datasources/local/consumer_local_datasource.dart';

final consumerRepositoryProvider = Provider<ConsumerRepositoryImpl>((ref) {
  return ConsumerRepositoryImpl(
    ref.read(consumerRemoteProvider),
    ref.read(consumerLocalProvider),
  );
});

class ConsumerRepositoryImpl implements IConsumerRepository {
  final ConsumerRemoteDatasource _remote;
  final ConsumerLocalDatasource _local;

  ConsumerRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, ConsumerEntity>> getConsumerByAuthId(String authId) async {
    final cached = _local.getConsumerProfileCache(authId);
    if (cached != null) {
      return Right(cached.toEntity());
    }
    return _fetchAndCache(authId);
  }

  @override
  Future<Either<Failure, ConsumerEntity?>> getConsumerByDocId(String docId) async {
    if (docId.isEmpty) return const Right(null);
    try {
      final model = await _remote.getConsumerByDocId(docId);
      return Right(model?.toEntity());
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, ConsumerEntity>> refreshConsumerProfile(
      String authId) async {
    return _fetchAndCache(authId);
  }

  Future<Either<Failure, ConsumerEntity>> _fetchAndCache(String authId) async {
    try {
      final model = await _remote.getConsumerByAuthId(authId);
      if (model == null) {
        return const Left(ApiFailure(message: 'Consumer not found'));
      }
      final entity = model.toEntity();
      await _local.saveConsumerProfileCache(entity);
      return Right(entity);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConsumerEntity>> updateConsumer(
    String authId,
    ConsumerEntity updates,
  ) async {
    try {
      final payload = {
        if (updates.displayName.isNotEmpty) 'displayName': updates.displayName,
        'bio': updates.bio,
        'profilePicture': updates.profilePicture,
      };
      final model = await _remote.updateConsumer(authId, payload);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConsumerEntity>> uploadProfilePicture(
    String authId,
    dynamic imageFile,
  ) async {
    try {
      if (imageFile is! File) {
        return Left(ApiFailure(message: 'Invalid image file'));
      }
      final model = await _remote.uploadProfilePicture(authId, imageFile);
      final entity = model.toEntity();
      await _local.saveConsumerProfileCache(entity);
      return Right(entity);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
