import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: repo);
});

class GetCurrentUserUsecase implements UsecaseWithoutParms<AuthEntity> {
  final IAuthRepository _repo;
  GetCurrentUserUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _repo.getCurrentUser();
  }
}
