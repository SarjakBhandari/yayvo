import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: repo);
});

class LogoutUsecase implements UsecaseWithoutParms<bool> {
  final IAuthRepository _repo;
  LogoutUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _repo.logout();
  }
}
