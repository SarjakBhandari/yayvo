import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final AuthEntity user;
  const RegisterParams(this.user);

  @override
  List<Object?> get props => [user];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: repo);
});

class RegisterUsecase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _repo;
  RegisterUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    return _repo.register(params.user);
  }
}
