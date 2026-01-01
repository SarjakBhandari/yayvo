import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart' show Failure;

abstract interface class UsecaseWithParms<SucessType, Params> {
  // usecase making for the usecases which has paraneters on function
  Future<Either<Failure, SucessType>> call(Params params);
}

abstract interface class UsecaseWithoutParms<SuccessType> {
  // same but without parameters
  Future<Either<Failure, SuccessType>> call();
}
