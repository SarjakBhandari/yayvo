import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../entities/review_entity.dart';
import '../entities/paginated_reviews.dart';

abstract interface class IReviewRepository {
  Future<Either<Failure, ReviewEntity>> createReview(ReviewEntity review);
  Future<Either<Failure, ReviewEntity>> updateReview(
    String id,
    ReviewEntity updates,
  );
  Future<Either<Failure, bool>> deleteReview(String id);
  Future<Either<Failure, PaginatedReviews>> getReviewsPaginated(
    Map<String, dynamic>? params,
  );
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByAuthor(String authorId);
  Future<Either<Failure, bool>> likeReview(String reviewId, String userId);
  Future<Either<Failure, bool>> unlikeReview(String reviewId, String userId);
  Future<bool> isReviewLiked(String reviewId, String userId);
  Future<Either<Failure, void>> uploadReviewImage(String reviewId, dynamic imageFile);
}
