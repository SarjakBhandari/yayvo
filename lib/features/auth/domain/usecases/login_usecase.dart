import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  final UserType userType;

  const LoginParams({
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, userType];
}

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: repo);
});

class LoginUsecase implements UsecaseWithParms<AuthEntity, LoginParams> {
  final IAuthRepository _repo;
  LoginUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _repo.login(params.email, params.password, params.userType);
  }
}
