import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import '../../models/consumer_api_model.dart';

final consumerRemoteProvider = Provider<ConsumerRemoteDatasource>((ref) {
  return ConsumerRemoteDatasource(ref.read(apiClientProvider));
});

class ConsumerRemoteDatasource {
  final ApiClient _client;
  ConsumerRemoteDatasource(this._client);

  Future<ConsumerApiModel?> getConsumerByAuthId(String authId) async {
    final url = ApiEndpoints.getConsumerByAuthId(authId);
    final resp = await _client.get(url);
    final raw = resp.data;
    if (raw == null) return null;
    final map = raw is Map ? Map<String, dynamic>.from(raw) : null;
    if (map == null) return null;
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;
    return ConsumerApiModel.fromJson(data);
  }

  /// Fetch consumer by document _id (e.g. review authorId).
  Future<ConsumerApiModel?> getConsumerByDocId(String docId) async {
    if (docId.isEmpty) return null;
    try {
      final url = ApiEndpoints.getConsumerByDocId(docId);
      final resp = await _client.get(url);
      final raw = resp.data;
      if (raw == null) return null;
      final map = raw is Map ? Map<String, dynamic>.from(raw) : null;
      if (map == null) return null;
      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;
      return ConsumerApiModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<ConsumerApiModel> updateConsumer(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final url = ApiEndpoints.updateConsumer(id);
    final resp = await _client.put(url, data: payload);
    final raw = resp.data;
    final data = raw is Map ? Map<String, dynamic>.from(raw) : null;
    if (data != null) {
      final inner = data['data'] is Map ? Map<String, dynamic>.from(data['data'] as Map) : data;
      return ConsumerApiModel.fromJson(inner);
    }
    return ConsumerApiModel.fromJson({});
  }

  /// Profile picture upload: matches frontend (temp) — PUT /api/consumers/:id/profile-picture, field "profilePicture".
  /// Uses authId in path first; on 404 retries with consumer document _id if available.
  Future<ConsumerApiModel> uploadProfilePicture(String authId, File imageFile) async {
    final consumer = await getConsumerByAuthId(authId);
    final path = imageFile.path;
    final name = path.split(Platform.pathSeparator).last;

    Future<Response> doUpload(String url) async {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(path, filename: name),
      });
      return _client.uploadFilePut(url, formData: formData);
    }

    try {
      String url = ApiEndpoints.updateConsumerProfilePicture(authId);
      var resp = await doUpload(url);
      var raw = resp.data;
      if (raw != null && raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final data = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : map;
        if (data.isNotEmpty) return ConsumerApiModel.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 &&
          consumer?.id != null &&
          consumer!.id != authId) {
        final url = ApiEndpoints.updateConsumerProfilePicture(consumer.id!);
        final resp = await doUpload(url);
        final raw = resp.data;
        if (raw != null && raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          final data = map['data'] is Map
              ? Map<String, dynamic>.from(map['data'] as Map)
              : map;
          if (data.isNotEmpty) return ConsumerApiModel.fromJson(data);
        }
      }
      rethrow;
    }
    final updated = await getConsumerByAuthId(authId);
    return updated ?? ConsumerApiModel(displayName: '', authId: authId);
  }
}
