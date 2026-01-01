import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

class GetUserByIdParams extends Equatable {
  final String authId;
  final UserType userType;
  const GetUserByIdParams({required this.authId, required this.userType});

  @override
  List<Object?> get props => [authId, userType];
}

final getUserByIdUsecaseProvider = Provider<GetUserByIdUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetUserByIdUsecase(authRepository: repo);
});

class GetUserByIdUsecase implements UsecaseWithParms<AuthEntity, GetUserByIdParams> {
  final IAuthRepository _repo;
  GetUserByIdUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(GetUserByIdParams params) {
    return _repo.getUserById(params.authId, params.userType);
  }
}
