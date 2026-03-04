import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_endpoints.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());

    // Auto retry on network failures (skip retry for FormData - it cannot be reused)
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          if (error.requestOptions.data is FormData) return false;
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Only add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  /// Registers a callback to run on 401 (e.g. clear auth state and navigate to login).
  void setOnUnauthorized(void Function()? callback) {
    _AuthInterceptor.onUnauthorized = callback;
  }

  // GET request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart request for file uploads (FormData must not be reused; use fresh per request).
  Future<Response> uploadFile(
      String path, {
        required FormData formData,
        Options? options,
        ProgressCallback? onSendProgress,
      }) async {
    final opts = options ?? Options();
    final sendTimeout = opts.sendTimeout ?? const Duration(seconds: 60);
    return _dio.post(
      path,
      data: formData,
      options: opts.copyWith(sendTimeout: sendTimeout),
      onSendProgress: onSendProgress,
    );
  }

  /// PUT with FormData (e.g. profile picture upload to match frontend).
  Future<Response> uploadFilePut(
      String path, {
        required FormData formData,
        Options? options,
        ProgressCallback? onSendProgress,
      }) async {
    final opts = options ?? Options();
    final sendTimeout = opts.sendTimeout ?? const Duration(seconds: 60);
    final h = Map<String, dynamic>.from(opts.headers ?? {});
    h.remove('Content-Type');
    h.remove('content-type');
    return _dio.put(
      path,
      data: formData,
      options: opts.copyWith(sendTimeout: sendTimeout, contentType: null, headers: h),
      onSendProgress: onSendProgress,
    );
  }
}

// Auth Interceptor to add JWT token to requests
class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  /// Called when a 401 is received; set by the app to navigate to login and clear auth state.
  static void Function()? onUnauthorized;

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (options.data is FormData) {
      final headers = Map<String, dynamic>.from(options.headers);
      headers.remove('Content-Type');
      headers.remove('content-type');
      headers.remove('contentType');
      options.headers = headers;
    }
    // Public endpoints (no auth required)
    final publicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.registrationConsumer,
      // add ApiEndpoints.registrationRetailer if needed
    ];

    final isPublicEndpoint =
    publicEndpoints.any((endpoint) => options.path.startsWith(endpoint));

    if (!isPublicEndpoint) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      _storage.delete(key: _tokenKey);
      _AuthInterceptor.onUnauthorized?.call();
    }
    handler.next(err);
  }
}