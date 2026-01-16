import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterUserParams {
  final AuthEntity authEntity;
  final ConsumerEntity consumerEntity;
  RegisterUserParams({required this.authEntity, required this.consumerEntity});
}

class RegisterUser implements UsecaseWithParms<AuthEntity, RegisterUserParams> {
  final IAuthRepository repository;
  RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(RegisterUserParams params) {
    return repository.register(params.authEntity, params.consumerEntity);
  }
}

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.read(authRepositoryProvider));
});