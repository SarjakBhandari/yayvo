import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../entities/consumer_entity.dart';

abstract interface class IConsumerRepository {
  Future<Either<Failure, ConsumerEntity>> getConsumerByAuthId(String authId);
  /// Fetch consumer by document _id (e.g. review authorId).
  Future<Either<Failure, ConsumerEntity?>> getConsumerByDocId(String docId);
  /// Force fetch from API and update cache (e.g. pull-to-refresh).
  Future<Either<Failure, ConsumerEntity>> refreshConsumerProfile(String authId);
  Future<Either<Failure, ConsumerEntity>> updateConsumer(
    String authId,
    ConsumerEntity updates,
  );
  Future<Either<Failure, ConsumerEntity>> uploadProfilePicture(
    String authId,
    dynamic imageFile,
  );
}
