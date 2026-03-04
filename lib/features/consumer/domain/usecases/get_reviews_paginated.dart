import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/paginated_reviews.dart';
import '../../domain/repositories/i_review_repository.dart';

class GetReviewsPaginated implements UsecaseWithParms<PaginatedReviews, Map<String, dynamic>?> {
  final IReviewRepository repository;

  GetReviewsPaginated(this.repository);

  @override
  Future<Either<Failure, PaginatedReviews>> call(Map<String, dynamic>? params) {
    return repository.getReviewsPaginated(params);
  }
}
