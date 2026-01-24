// features/consumer/profile/domain/repositories/profile_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

abstract class ProfileRepository {
  Future<ConsumerEntity> getConsumerById(String authId);
  Future<ConsumerEntity> updateConsumer(ConsumerEntity consumer);
  Future<ConsumerEntity> uploadProfilePicture(String authId, String filePath);
}

