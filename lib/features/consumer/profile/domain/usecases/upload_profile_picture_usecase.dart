import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

import '../../data/repositories/profile_repository.dart';
import '../repositories/profile_repository.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
class UploadProfilePictureUseCase {
  final ProfileRepository repository;
  final UserSessionService sessionService;

  UploadProfilePictureUseCase(
      this.repository,
      this.sessionService,
      );

  Future<ConsumerEntity> call(XFile image) async {
    final session = await sessionService.getUserSession();
    final authId = session?.userId;

    if (authId == null) {
      throw Exception('User not authenticated');
    }

    return repository.uploadProfilePicture(
      authId,
      image.path,
    );
  }
}

final uploadProfilePictureUseCaseProvider =
Provider<UploadProfilePictureUseCase>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  final sessionService = ref.read(userSessionServiceProvider);
  return UploadProfilePictureUseCase(repo, sessionService);
});
