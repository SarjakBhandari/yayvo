import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String passwordHash;

  const LoginParams({
    required this.email,
    required this.passwordHash,
  });

  LoginParams copyWith({
    String? email,
    String? passwordHash,
  }) {
    return LoginParams(
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  @override
  String toString() => 'LoginParams(email: $email, passwordHash: $passwordHash)';
}

class LoginUser implements UsecaseWithParms<AuthEntity, LoginParams> {
  final IAuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.login(params.email, params.passwordHash);
  }
}

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.read(authRepositoryProvider));
});