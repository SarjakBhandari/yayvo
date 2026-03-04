import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, ProductEntity>> getProductById(String id);
  Future<Either<Failure, bool>> likeProduct(String productId, String userId);
  Future<Either<Failure, bool>> unlikeProduct(String productId, String userId);
  Future<bool> isProductLiked(String productId, String userId);
}
