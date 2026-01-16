import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UsecaseWithoutParms<AuthEntity> {
  final IAuthRepository repository;
  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return repository.getCurrentUser();
  }
}

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});