import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_review_repository.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';

class CreateReview implements UsecaseWithParms<ReviewEntity, ReviewEntity> {
  final IReviewRepository repository;
  CreateReview(this.repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(ReviewEntity params) {
    return repository.createReview(params);
  }
}
