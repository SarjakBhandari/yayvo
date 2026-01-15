import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class GetUserById implements UsecaseWithParms<AuthEntity, String> {
  final IAuthRepository repository;
  GetUserById(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(String authId) {
    return repository.getUserById(authId);
  }
}

final getUserByIdProvider = Provider<GetUserById>((ref) {
  return GetUserById(ref.read(authRepositoryProvider));
});