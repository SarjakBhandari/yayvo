// features/consumer/profile/data/repositories/profile_repository_impl.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:yayvo/core/api/api_endpoints.dart';
import 'package:yayvo/core/providers/dio_providor.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl(this._dio);

  @override
  Future<ConsumerEntity> getConsumerById(String authId) async {
    final response = await _dio.get(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.getConsumerById(authId)}',
    );

    // defensive parsing
    final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
    if (data == null || data is! Map) {
      throw Exception('Unexpected response format when fetching consumer');
    }

    return ConsumerEntity(
      authId: data['authid']?.toString() ?? authId,
      fullName: data['fullName']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      phoneNumber: data['phone_number']?.toString() ?? '',
      dob: data['dob']?.toString(),
      gender: data['gender']?.toString(),
      country: data['country']?.toString(),
      profilePicture: data['profile_picture']?.toString() ?? "/uploads/profilepicture/$authId.jpg",
    );
  }

  @override
  Future<ConsumerEntity> updateConsumer(ConsumerEntity consumer) async {
    final response = await _dio.put(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.updateConsumer(consumer.authId ?? "")}',
      data: {
        'full_name': consumer.fullName,
        'username': consumer.username,
        'phone_number': consumer.phoneNumber,
        'dob': consumer.dob,
        'gender': consumer.gender,
        'country': consumer.country,
      },
      options: Options(validateStatus: (status) => status != null),
    );

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      // include server body for debugging
      throw Exception('Update failed: ${response.statusCode} - ${response.data}');
    }

    final data = response.data is Map ? response.data : response.data['data'];
    return ConsumerEntity(
      authId: data['auth_id']?.toString() ?? consumer.authId ?? '',
      fullName: data['full_name']?.toString() ?? consumer.fullName ?? '',
      username: data['username']?.toString() ?? consumer.username ?? '',
      phoneNumber: data['phone_number']?.toString() ?? consumer.phoneNumber ?? '',
      dob: data['dob']?.toString(),
      gender: data['gender']?.toString(),
      country: data['country']?.toString(),
      profilePicture: data['profile_picture']?.toString() ?? "/uploads/profilepicture/${consumer.authId}.jpg",
    );
  }

  @override
  Future<ConsumerEntity> uploadProfilePicture(String authId, String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    // Determine mime type
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    final contentType = MediaType(parts[0], parts.length > 1 ? parts[1] : 'jpeg');

    final multipart = await MultipartFile.fromFile(
      file.path,
      filename: '$authId.jpg',
      contentType: contentType,
    );

    // Field name must match server expectation. Change if server expects 'profile_picture' or 'profilePicture'
    const fieldName = 'profilePicture';

    final formData = FormData.fromMap({
      fieldName: multipart,
      // add other fields if server expects them, e.g. 'authId': authId
    });

    // Use validateStatus so we can inspect server body on non-2xx
    final response = await _dio.put(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.updateConsumerProfilePicture(authId)}',
      data: formData,
      options: Options(
        headers: {
          // Dio sets Content-Type for multipart automatically; explicit header is optional
          // 'Content-Type': 'multipart/form-data',
        },
        validateStatus: (status) => status != null,
      ),
    );

    // Log for debugging (LogInterceptor also helps)
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      // Throw with server body so caller can show or log it
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Upload failed: ${response.statusCode} - ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
    if (data == null || data is! Map) {
      throw Exception('Unexpected response format from upload endpoint');
    }

    return ConsumerEntity(
      authId: data['auth_id']?.toString() ?? authId,
      fullName: data['full_name']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      phoneNumber: data['phone_number']?.toString() ?? '',
      dob: data['dob']?.toString(),
      gender: data['gender']?.toString(),
      country: data['country']?.toString(),
      profilePicture: data['profile_picture']?.toString() ?? "/uploads/profilepicture/$authId.jpg",
    );
  }
}

// Provider override — use the configured Dio from dioProvider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileRepositoryImpl(dio);
});
