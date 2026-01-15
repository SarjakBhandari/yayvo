import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserParams {
  final String authId;
  final ConsumerEntity consumerEntity;
  UpdateUserParams({required this.authId, required this.consumerEntity});
}

class UpdateUser implements UsecaseWithParms<ConsumerEntity, UpdateUserParams> {
  final IAuthRepository repository;
  UpdateUser(this.repository);

  @override
  Future<Either<Failure, ConsumerEntity>> call(UpdateUserParams params) {
    return repository.updateUser(params.authId, params.consumerEntity);
  }
}

final updateUserProvider = Provider<UpdateUser>((ref) {
  return UpdateUser(ref.read(authRepositoryProvider));
});