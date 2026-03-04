import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/consumer/data/models/product_api_model.dart';
import 'package:yayvo/features/consumer/data/models/product_cache_hive_model.dart';

final productLocalProvider = Provider<ProductLocalDatasource>((ref) {
  return ProductLocalDatasource(ref.read(hiveServiceProvider));
});

class ProductLocalDatasource {
  final HiveService _hive;

  ProductLocalDatasource(this._hive);

  Future<void> cacheProducts(List<ProductApiModel> list) async {
    await _hive.saveProductsCache(
      list.map((e) => ProductCacheHiveModel.fromApi(e)).toList(),
    );
  }

  List<ProductApiModel> getCachedProducts() {
    return _hive.getCachedProducts().map((e) => e.toApi()).toList();
  }
}
