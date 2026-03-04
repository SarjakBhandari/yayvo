import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';

final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(
    ref.read(productRemoteProvider),
    ref.read(productLocalProvider),
    ref.read(networkInfoProvider),
  );
});

class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDatasource _remote;
  final ProductLocalDatasource _local;
  final INetworkInfo _networkInfo;

  ProductRepositoryImpl(this._remote, this._local, this._networkInfo);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final list = await _remote.getProducts(search: search, page: page, limit: limit);
        if (page == 1) await _local.cacheProducts(list);
        return Right(list.map((e) => e.toEntity()).toList());
      } catch (e) {
        if (page == 1) {
          final cached = _local.getCachedProducts();
          if (cached.isNotEmpty) {
            return Right(
              cached.map((e) => e.toEntity()).toList(),
            );
          }
        }
        return Left(ApiFailure(message: e.toString()));
      }
    }
    final cached = _local.getCachedProducts();
    if (cached.isNotEmpty) {
      return Right(cached.map((e) => e.toEntity()).toList());
    }
    return const Left(ApiFailure(message: 'Offline. No cached products.'));
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final model = await _remote.getProductById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> likeProduct(String productId, String userId) async {
    try {
      await _remote.likeProduct(productId, userId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unlikeProduct(String productId, String userId) async {
    try {
      await _remote.unlikeProduct(productId, userId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isProductLiked(String productId, String userId) async {
    try {
      return await _remote.isProductLiked(productId, userId);
    } catch (_) {
      return false;
    }
  }
}
