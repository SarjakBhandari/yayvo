// features/consumer/profile/domain/usecases/get_consumer_usecase.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import '../../data/repositories/profile_repository.dart';
import '../repositories/profile_repository.dart';

class GetConsumerUseCase {
  final ProfileRepository repository;
  GetConsumerUseCase(this.repository);

  Future<ConsumerEntity> call(String id) => repository.getConsumerById(id);
}

final getConsumerUseCaseProvider = Provider<GetConsumerUseCase>((ref) {
  return GetConsumerUseCase(ref.read(profileRepositoryProvider));
});