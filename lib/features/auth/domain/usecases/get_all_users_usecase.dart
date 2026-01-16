import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';
import 'package:yayvo/features/auth/data/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';

class GetAllUsers implements UsecaseWithoutParms<List<ConsumerEntity>> {
  final IAuthRepository repository;
  GetAllUsers(this.repository);

  @override
  Future<Either<Failure, List<ConsumerEntity>>> call() {
    return repository.getAllUsers();
  }
}

final getAllUsersProvider = Provider<GetAllUsers>((ref) {
  return GetAllUsers(ref.read(authRepositoryProvider));
});