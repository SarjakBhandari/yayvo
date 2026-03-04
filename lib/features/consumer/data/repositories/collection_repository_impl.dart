import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_collection_repository.dart';
import '../datasources/local/collection_local_datasource.dart';
import '../datasources/remote/collection_remote_datasource.dart';

final collectionRepositoryProvider = Provider<CollectionRepositoryImpl>((ref) {
  return CollectionRepositoryImpl(
    ref.read(collectionRemoteProvider),
    ref.read(collectionLocalProvider),
    ref.read(networkInfoProvider),
  );
});

class CollectionRepositoryImpl implements ICollectionRepository {
  final CollectionRemoteDatasource _remote;
  final CollectionLocalDatasource _local;
  final INetworkInfo _networkInfo;

  CollectionRepositoryImpl(this._remote, this._local, this._networkInfo);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getSavedReviews(String authId) async {
    if (await _networkInfo.isConnected) {
      try {
        final list = await _remote.getSavedReviews(authId);
        await _local.cacheSavedReviews(authId, list);
        return Right(list.map((e) => e.toEntity()).toList());
      } catch (e) {
        final cached = _local.getCachedSavedReviews(authId);
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
        return Left(ApiFailure(message: e.toString()));
      }
    }
    final cached = _local.getCachedSavedReviews(authId);
    return Right(cached.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getSavedProducts(String authId) async {
    if (await _networkInfo.isConnected) {
      try {
        final list = await _remote.getSavedProducts(authId);
        await _local.cacheSavedProducts(authId, list);
        return Right(list.map((e) => e.toEntity()).toList());
      } catch (e) {
        final cached = _local.getCachedSavedProducts(authId);
        if (cached.isNotEmpty) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
        return Left(ApiFailure(message: e.toString()));
      }
    }
    final cached = _local.getCachedSavedProducts(authId);
    return Right(cached.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Either<Failure, bool>> saveReview(String authId, String reviewId) async {
    try {
      await _remote.saveReview(authId, reviewId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveReview(String authId, String reviewId) async {
    try {
      await _remote.unsaveReview(authId, reviewId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveProduct(String authId, String productId) async {
    try {
      await _remote.saveProduct(authId, productId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveProduct(String authId, String productId) async {
    try {
      await _remote.unsaveProduct(authId, productId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
