import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

class GetUserTypeParams extends Equatable {
  final String authId;
  const GetUserTypeParams(this.authId);

  @override
  List<Object?> get props => [authId];
}

final getUserTypeUsecaseProvider = Provider<GetUserTypeUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetUserTypeUsecase(authRepository: repo);
});

class GetUserTypeUsecase implements UsecaseWithParms<UserType, GetUserTypeParams> {
  final IAuthRepository _repo;
  GetUserTypeUsecase({required IAuthRepository authRepository}) : _repo = authRepository;

  @override
  Future<Either<Failure, UserType>> call(GetUserTypeParams params) {
    return _repo.getUserType(params.authId);
  }
}
