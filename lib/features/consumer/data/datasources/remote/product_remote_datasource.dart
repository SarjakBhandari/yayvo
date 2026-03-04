import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import 'package:yayvo/core/api/response_parser.dart';
import 'package:yayvo/features/consumer/data/models/product_api_model.dart';

final productRemoteProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(ref.read(apiClientProvider));
});

class ProductRemoteDatasource {
  final ApiClient _client;
  ProductRemoteDatasource(this._client);

  Future<List<ProductApiModel>> getProducts({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    final resp = await _client.get(
      ApiEndpoints.productsPaginated,
      queryParameters: queryParams,
    );
    final list = responseToList(resp.data);
    final models = <ProductApiModel>[];
    for (final e in list) {
      if (e is! Map) continue;
      try {
        final m = ProductApiModel.fromJson(Map<String, dynamic>.from(e));
        if (m.id.isNotEmpty) models.add(m);
      } catch (_) {}
    }
    return models;
  }

  Future<ProductApiModel> getProductById(String id) async {
    final url = ApiEndpoints.productById(id);
    final resp = await _client.get(url);
    final data = resp.data;
    if (data == null) throw Exception('Product not found');
    final map = data is Map ? Map<String, dynamic>.from(data) : null;
    if (map == null) throw Exception('Invalid product response');
    return ProductApiModel.fromJson(map);
  }

  Future<void> likeProduct(String productId, String userId) async {
    await _client.post(
      ApiEndpoints.productsLike,
      data: {'productId': productId, 'userId': userId},
    );
  }

  Future<void> unlikeProduct(String productId, String userId) async {
    await _client.post(
      ApiEndpoints.productsUnlike,
      data: {'productId': productId, 'userId': userId},
    );
  }

  Future<bool> isProductLiked(String productId, String userId) async {
    try {
      final resp = await _client.get(
        ApiEndpoints.productsIsLiked,
        queryParameters: {'productId': productId, 'userId': userId},
      );
      final data = resp.data;
      if (data is bool) return data;
      if (data is Map) return data['liked'] == true;
      return false;
    } catch (_) {
      return false;
    }
  }
}
