// domain/usecases/update_consumer_usecase.dart
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

import '../../data/repositories/profile_repository.dart';
import '../repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateConsumerUseCase {
  final ProfileRepository repository;
  UpdateConsumerUseCase(this.repository);

  Future<ConsumerEntity> call(ConsumerEntity consumer) {
    return repository.updateConsumer(consumer);
  }
}

// Provider
final updateConsumerUseCaseProvider = Provider<UpdateConsumerUseCase>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return UpdateConsumerUseCase(repo);
});