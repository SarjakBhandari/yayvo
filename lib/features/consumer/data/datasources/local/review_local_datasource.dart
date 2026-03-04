import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/consumer/data/models/review_api_model.dart';
import 'package:yayvo/features/consumer/data/models/review_cache_hive_model.dart';

final reviewLocalProvider = Provider<ReviewLocalDatasource>((ref) {
  return ReviewLocalDatasource(ref.read(hiveServiceProvider));
});

class ReviewLocalDatasource {
  final HiveService _hive;

  ReviewLocalDatasource(this._hive);

  Future<void> cacheReviews(List<ReviewApiModel> list) async {
    await _hive.saveReviewsCache(
      list.map((e) => ReviewCacheHiveModel.fromApi(e)).toList(),
    );
  }

  List<ReviewApiModel> getCachedReviews() {
    return _hive.getCachedReviews().map((e) => e.toApi()).toList();
  }
}
