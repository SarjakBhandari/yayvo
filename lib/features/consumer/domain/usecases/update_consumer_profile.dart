import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../../domain/entities/consumer_entity.dart';
import '../../domain/repositories/i_consumer_repository.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';

class UpdateConsumerProfile
    implements UsecaseWithParms<ConsumerEntity, Map<String, dynamic>> {
  final IConsumerRepository repository;
  UpdateConsumerProfile(this.repository);

  @override
  Future<Either<Failure, ConsumerEntity>> call(Map<String, dynamic> params) {
    final authId = params['authId'] as String;
    final updates = params['consumer'] as ConsumerEntity;
    return repository.updateConsumer(authId, updates);
  }
}
