import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

class DeleteUserParams {
  final String authId;
  final UserType role;
  DeleteUserParams({required this.authId, required this.role});
}

class DeleteUser implements UsecaseWithParms<bool, DeleteUserParams> {
  final IAuthRepository repository;
  DeleteUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteUserParams params) {
    return repository.deleteUser(params.authId, params.role);
  }
}

final deleteUserProvider = Provider<DeleteUser>((ref) {
  return DeleteUser(ref.read(authRepositoryProvider));
});