import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:yayvo/features/auth/data/datasources/auth_datasource.dart';
import 'package:yayvo/features/auth/data/models/auth_api_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_api_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

final authRemoteProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService {
    _addLoggingInterceptor();
  }

  void _addLoggingInterceptor() {
    _apiClient.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // debug print
          // ignore: avoid_print
          print('DIO REQUEST -> ${options.method} ${options.uri}');
          // ignore: avoid_print
          print('DIO REQUEST DATA -> ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('DIO RESPONSE -> ${response.data}');
          return handler.next(response);
        },
        onError: (err, handler) {
          // ignore: avoid_print
          print('DIO ERROR -> ${err.response?.data ?? err.message}');
          return handler.next(err);
        },
      ),
    );
  }

  @override
  Future<AuthApiModel?> login(String email, String passwordHash) async {
    final normalizedEmail = email.trim().toLowerCase();
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': normalizedEmail, 'password': passwordHash},
    );

    final data = response.data;
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    if (map['success'] == false) return null;

    // Token: top-level or inside data
    String? token = map['token'] is String ? map['token'] as String : null;
    if (token == null && map['data'] is Map) {
      final inner = Map<String, dynamic>.from(map['data'] as Map);
      token = inner['token'] is String ? inner['token'] as String : null;
      token ??= inner['accessToken'] is String
          ? inner['accessToken'] as String
          : null;
    }
    token ??= map['accessToken'] is String
        ? map['accessToken'] as String
        : null;
    token ??= map['jwt'] is String ? map['jwt'] as String : null;
    if (token == null || token.isEmpty) return null;

    // User payload: user or data
    Map<String, dynamic> userMap = {};
    if (map['user'] is Map) {
      userMap = Map<String, dynamic>.from(map['user'] as Map);
    } else if (map['data'] is Map) {
      userMap = Map<String, dynamic>.from(map['data'] as Map);
      userMap.remove('token');
      userMap.remove('accessToken');
      if (userMap['user'] is Map) {
        userMap = Map<String, dynamic>.from(userMap['user'] as Map);
      }
    }

    // Some APIs return user fields directly at top-level with token
    if (userMap.isEmpty &&
        (map.containsKey('email') ||
            map.containsKey('_id') ||
            map.containsKey('id') ||
            map.containsKey('authId'))) {
      userMap = Map<String, dynamic>.from(map)
        ..remove('token')
        ..remove('accessToken')
        ..remove('jwt')
        ..remove('success')
        ..remove('message');
    }

    if (userMap.isEmpty) return null;

    final user = AuthApiModel.fromJson({...userMap, 'token': token});

    await _userSessionService.saveUserSession(
      UserSession(
        userId: user.id ?? '',
        email: user.email.isEmpty ? normalizedEmail : user.email,
        role: user.role.toString(),
      ),
    );
    await _userSessionService.saveAuthToken(token);
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: 'auth_token', value: token);

    return user;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final payload = user.toJson();
    final response = await _apiClient.post(
      ApiEndpoints.registrationConsumer,
      data: payload,
    );

    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      if (kDebugMode) {}
      return AuthApiModel.fromJson(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<ConsumerApiModel> registerConsumer(ConsumerApiModel consumer) async {
    final response = await _apiClient.post(
      ApiEndpoints.registrationConsumer,
      data: consumer.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      return ConsumerApiModel.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<ConsumerApiModel> updateConsumer(ConsumerApiModel consumer) async {
    if (consumer.authId == null || consumer.authId!.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(
          path: "${ApiEndpoints.baseUrl}consumers/",
        ),
        error: "Missing authId for consumer update",
        type: DioExceptionType.badResponse,
      );
    }
    final response = await _apiClient.put(
      "${ApiEndpoints.baseUrl}consumers/${consumer.authId}",
      data: consumer.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      return ConsumerApiModel.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<AuthApiModel?> getUserById(String authId, UserType userType) async {
    final response = await _apiClient.get(
      "${ApiEndpoints.baseUrl}users/$authId",
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> getUserByEmail(String email, UserType userType) async {
    final response = await _apiClient.get(
      "${ApiEndpoints.baseUrl}users/email/$email",
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<bool> updateUser(AuthApiModel user) async {
    final response = await _apiClient.put(
      "${ApiEndpoints.baseUrl}users/${user.id}",
      data: user.toJson(),
    );
    return response.data['success'] == true;
  }

  @override
  Future<bool> deleteUser(String authId, UserType userType) async {
    final response = await _apiClient.delete(
      "${ApiEndpoints.baseUrl}users/$authId",
    );
    return response.data['success'] == true;
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final session = _userSessionService.getUserSession();
    if (session != null) return getUserById(session.userId, UserType.consumer);
    return null;
  }

  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    return true;
  }

  @override
  Future<UserType?> getUserType(String authId) async {
    final user = await getUserById(authId, UserType.consumer);
    return user != null ? UserType.consumer : null;
  }

  @override
  Future<ConsumerApiModel?> getConsumerById(String authId) async {
    final response = await _apiClient.get(
      "${ApiEndpoints.baseUrl}consumers/$authId",
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ConsumerApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<List<ConsumerApiModel>> getAllConsumers() async {
    final response = await _apiClient.get("${ApiEndpoints.baseUrl}consumers");
    if (response.data['success'] == true) {
      final list = response.data['data'] as List<dynamic>;
      return list
          .map(
            (json) => ConsumerApiModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }
}
