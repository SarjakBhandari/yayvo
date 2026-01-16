import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser implements UsecaseWithoutParms<bool> {
  final IAuthRepository repository;
  LogoutUser(this.repository);

  @override
  Future<Either<Failure, bool>> call() {
    return repository.logout();
  }
}

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.read(authRepositoryProvider));
});