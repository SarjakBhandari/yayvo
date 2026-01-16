import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  // ---------- Auth ----------

  @override
  Future<AuthApiModel?> login(String email, String passwordHash) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': passwordHash},
    );

    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save full session
      await _userSessionService.saveUserSession(
        UserSession(
          userId: user.id ?? '',
          email: user.email,
          role: user.role.toString()
        ),
      );
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.registrationConsumer,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<AuthApiModel?> getUserById(String authId, UserType userType) async {
    final response = await _apiClient.get("${ApiEndpoints.baseUrl}users/$authId");

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> getUserByEmail(String email, UserType userType) async {
    final response = await _apiClient.get("${ApiEndpoints.baseUrl}users/email/$email");

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
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
    final response = await _apiClient.delete("${ApiEndpoints.baseUrl}users/$authId");
    return response.data['success'] == true;
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final session = _userSessionService.getUserSession();
    if (session != null) {
      return getUserById(session.userId, UserType.consumer);
    }
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

  // ---------- Consumer ----------

  @override
  Future<ConsumerApiModel> registerConsumer(ConsumerApiModel consumer) async {
    final response = await _apiClient.post(
      ApiEndpoints.registrationConsumer,
      data: consumer.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return ConsumerApiModel.fromJson(data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<ConsumerApiModel?> getConsumerById(String authId) async {
    final response = await _apiClient.get("${ApiEndpoints.baseUrl}consumers/$authId");

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
      return list.map((json) => ConsumerApiModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}