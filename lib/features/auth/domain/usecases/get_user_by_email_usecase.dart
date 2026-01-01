import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

class GetUserByEmailParams extends Equatable {
  final String email;
  final UserType userType;
  const GetUserByEmailParams({required this.email, required this.userType});

  @override
  List<Object?> get props => [email, userType];
}

final getUserByEmailUsecaseProvider = Provider<GetUserByEmailUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetUserByEmailUsecase(authRepository: repo);
});

class GetUserByEmailUsecase implements UsecaseWithParms<AuthEntity, GetUserByEmailParams> {
  final IAuthRepository _repo;
  GetUserByEmailUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(GetUserByEmailParams params) {
    return _repo.getUserByEmail(params.email, params.userType);
  }
}
