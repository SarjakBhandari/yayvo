import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../../domain/entities/consumer_entity.dart';
import '../../domain/repositories/i_consumer_repository.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';

class GetConsumerProfile implements UsecaseWithParms<ConsumerEntity, String> {
  final IConsumerRepository repository;
  GetConsumerProfile(this.repository);

  @override
  Future<Either<Failure, ConsumerEntity>> call(String authId) {
    return repository.getConsumerByAuthId(authId);
  }
}
