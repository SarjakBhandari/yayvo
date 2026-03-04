import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import 'package:yayvo/core/api/response_parser.dart';
import 'package:yayvo/features/consumer/data/models/review_api_model.dart';
import 'package:dio/dio.dart';

final reviewRemoteProvider = Provider<ReviewRemoteDatasource>((ref) {
  return ReviewRemoteDatasource(ref.read(apiClientProvider));
});

class ReviewRemoteDatasource {
  final ApiClient _client;
  ReviewRemoteDatasource(this._client);

  Future<ReviewApiModel> createReview(Map<String, dynamic> payload) async {
    final resp = await _client.post(ApiEndpoints.reviewsCreate, data: payload);
    final raw = resp.data;
    if (raw == null) return ReviewApiModel.fromJson({});
    final map = raw is Map ? Map<String, dynamic>.from(raw) : null;
    if (map == null) return ReviewApiModel.fromJson({});
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;
    return ReviewApiModel.fromJson(data);
  }

  Future<void> uploadReviewImage(String reviewId, FormData fd) async {
    final url = ApiEndpoints.reviewImage(reviewId);
    await _client.uploadFile(url, formData: fd);
  }

  /// Returns reviews from API. Handles: { data: { items: [] } }, { items: [] }, or direct list.
  Future<({List<ReviewApiModel> list, bool hasMore})> getReviewsPaginated(
    Map<String, dynamic>? params,
  ) async {
    final resp = await _client.get(
      ApiEndpoints.reviewsPaginated,
      queryParameters: params,
    );
    final raw = resp.data;
    List<dynamic> rawList = [];
    int currentPage = 1;
    int totalPages = 1;

    if (raw is List) {
      rawList = raw;
    } else if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      // data.items
      final data = map['data'];
      if (data is Map) {
        final inner = Map<String, dynamic>.from(data);
        final items = inner['items'];
        if (items is List) rawList = items;
        final pag = inner['pagination'];
        if (pag is Map) {
          final p = pag['page'];
          final tp = pag['totalPages'];
          if (p != null) currentPage = (p is int) ? p : int.tryParse(p.toString()) ?? 1;
          if (tp != null) totalPages = (tp is int) ? tp : int.tryParse(tp.toString()) ?? 1;
        }
      }
      if (rawList.isEmpty) {
        final items = map['items'];
        if (items is List) rawList = items;
      }
    }

    if (rawList.isEmpty) rawList = responseToList(raw);

    final list = <ReviewApiModel>[];
    for (final e in rawList) {
      try {
        final map = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        final model = ReviewApiModel.fromJson(map);
        if (model.id.isNotEmpty) list.add(model);
      } catch (_) {}
    }
    final hasMore = currentPage < totalPages;
    return (list: list, hasMore: hasMore);
  }

  /// Get reviews by author (e.g. for profile "My Reviews"). Returns list; shape may be data.items or data.
  Future<List<ReviewApiModel>> getReviewsByAuthor(String authorId) async {
    if (authorId.isEmpty) return [];
    final url = ApiEndpoints.reviewsByAuthor(authorId);
    final resp = await _client.get(url);
    final raw = resp.data;
    List<dynamic> rawList = [];
    if (raw is List) {
      rawList = raw;
    } else if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is List) rawList = data;
      else if (data is Map) {
        final inner = Map<String, dynamic>.from(data);
        final items = inner['items'];
        if (items is List) rawList = items;
      }
      if (rawList.isEmpty && map['items'] is List) rawList = map['items'] as List;
    }
    if (rawList.isEmpty) rawList = responseToList(raw);
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

  Future<void> likeReview(String reviewId, String userId) async {
    final url = ApiEndpoints.reviewLike(reviewId);
    await _client.post(url, data: {'userId': userId});
  }

  Future<void> unlikeReview(String reviewId, String userId) async {
    final url = ApiEndpoints.reviewUnlike(reviewId);
    await _client.post(url, data: {'userId': userId});
  }

  Future<bool> isReviewLiked(String reviewId, String userId) async {
    final url = ApiEndpoints.reviewIsLiked(reviewId, userId);
    final resp = await _client.get(url);
    final data = resp.data;
    if (data == true) return true;
    if (data is Map) {
      if (data['liked'] == true) return true;
      final inner = data['data'];
      if (inner is Map && inner['liked'] == true) return true;
    }
    return false;
  }
}
