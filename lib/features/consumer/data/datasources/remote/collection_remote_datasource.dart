import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import 'package:yayvo/core/api/response_parser.dart';
import 'package:yayvo/features/consumer/data/models/product_api_model.dart';
import 'package:yayvo/features/consumer/data/models/review_api_model.dart';

final collectionRemoteProvider = Provider<CollectionRemoteDatasource>((ref) {
  return CollectionRemoteDatasource(ref.read(apiClientProvider));
});

class CollectionRemoteDatasource {
  final ApiClient _client;

  CollectionRemoteDatasource(this._client);

  Future<List<ReviewApiModel>> getSavedReviews(String authId) async {
    final url = ApiEndpoints.savedReviews(authId);
    final resp = await _client.get(url);
    final raw = resp.data;
    List<dynamic> rawList = _extractItems(raw);
    final list = <ReviewApiModel>[];
    for (final e in rawList) {
      try {
        final map = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        final model = ReviewApiModel.fromJson(map);
        if (model.id.isNotEmpty) list.add(model);
      } catch (_) {}
    }
    return list;
  }

  Future<List<ProductApiModel>> getSavedProducts(String authId) async {
    final url = ApiEndpoints.savedProducts(authId);
    final resp = await _client.get(url);
    final raw = resp.data;
    List<dynamic> rawList = _extractItems(raw);
    final list = <ProductApiModel>[];
    for (final e in rawList) {
      try {
        final map = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        list.add(ProductApiModel.fromJson(map));
      } catch (_) {}
    }
    return list;
  }

  static List<dynamic> _extractItems(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is Map) {
        final inner = Map<String, dynamic>.from(data);
        final items = inner['items'];
        if (items is List) return items;
      }
      final items = map['items'];
      if (items is List) return items;
    }
    return responseToList(raw);
  }

  Future<void> saveReview(String consumerAuthId, String reviewId) async {
    await _client.post(ApiEndpoints.saveReview,
        data: {'consumerAuthId': consumerAuthId, 'reviewId': reviewId});
  }

  Future<void> unsaveReview(String consumerAuthId, String reviewId) async {
    await _client.post(ApiEndpoints.unsaveReview,
        data: {'consumerAuthId': consumerAuthId, 'reviewId': reviewId});
  }

  Future<void> saveProduct(String consumerAuthId, String productId) async {
    await _client.post(ApiEndpoints.saveProduct,
        data: {'consumerAuthId': consumerAuthId, 'productId': productId});
  }

  Future<void> unsaveProduct(String consumerAuthId, String productId) async {
    await _client.post(ApiEndpoints.unsaveProduct,
        data: {'consumerAuthId': consumerAuthId, 'productId': productId});
  }
}
