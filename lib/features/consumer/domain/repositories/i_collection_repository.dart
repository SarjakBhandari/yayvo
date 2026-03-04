import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../entities/product_entity.dart';
import '../entities/review_entity.dart';

abstract interface class ICollectionRepository {
  Future<Either<Failure, List<ReviewEntity>>> getSavedReviews(String authId);
  Future<Either<Failure, List<ProductEntity>>> getSavedProducts(String authId);
  Future<Either<Failure, bool>> saveReview(String authId, String reviewId);
  Future<Either<Failure, bool>> unsaveReview(String authId, String reviewId);
  Future<Either<Failure, bool>> saveProduct(String authId, String productId);
  Future<Either<Failure, bool>> unsaveProduct(String authId, String productId);
}
