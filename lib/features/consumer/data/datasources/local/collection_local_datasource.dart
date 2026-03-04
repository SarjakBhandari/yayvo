import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/consumer/data/models/product_api_model.dart';
import 'package:yayvo/features/consumer/data/models/review_api_model.dart';

final collectionLocalProvider = Provider<CollectionLocalDatasource>((ref) {
  return CollectionLocalDatasource(ref.read(hiveServiceProvider));
});

class CollectionLocalDatasource {
  final HiveService _hive;

  CollectionLocalDatasource(this._hive);

  Future<void> cacheSavedReviews(String authId, List<ReviewApiModel> list) async {
    await _hive.saveSavedReviewsCache(
      authId,
      list.map((e) => e.toJson()).toList(),
    );
  }

  List<ReviewApiModel> getCachedSavedReviews(String authId) {
    final list = _hive.getSavedReviewsCache(authId);
    return list.map((e) => ReviewApiModel.fromJson(e)).toList();
  }

  Future<void> cacheSavedProducts(String authId, List<ProductApiModel> list) async {
    await _hive.saveSavedProductsCache(
      authId,
      list.map((e) => e.toJson()).toList(),
    );
  }

  List<ProductApiModel> getCachedSavedProducts(String authId) {
    final list = _hive.getSavedProductsCache(authId);
    return list.map((e) => ProductApiModel.fromJson(e)).toList();
  }
}
