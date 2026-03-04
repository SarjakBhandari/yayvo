import 'package:dartz/dartz.dart';
import 'package:yayvo/core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import 'package:yayvo/core/usecases/app_usecases.dart';

class GetProducts implements UsecaseWithParms<List<ProductEntity>, Map<String, dynamic>?> {
  final IProductRepository repository;
  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(Map<String, dynamic>? params) {
    final search = params?['search'] as String?;
    final page = params?['page'] as int? ?? 1;
    final limit = params?['limit'] as int? ?? 20;
    return repository.getProducts(search: search, page: page, limit: limit);
  }
}
