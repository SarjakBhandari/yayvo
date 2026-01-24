import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/api/api_endpoints.dart';
import '../services/storage/user_session_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl, // Removed extra brace and quotes
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    validateStatus: (status) {
      // Accept all status codes to handle errors manually
      return status != null && status < 500;
    },
  ));

  // Add interceptor for authentication
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Get token asynchronously
      final userSession = ref.read(userSessionServiceProvider);
      final session = await userSession.getUserSession();
      final token = userSession.getAuthToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    },
    onError: (DioException error, handler) async {
      // Handle 401 Unauthorized - token expired or invalid
      if (error.response?.statusCode == 401) {
        // Clear session and redirect to login
        await ref.read(userSessionServiceProvider).clearSession();
        // You might want to trigger navigation to login here
        // or use a global navigator key
      }

      return handler.next(error);
    },
    onResponse: (response, handler) {
      // Optional: Log responses in debug mode
      // print('Response [${response.statusCode}]: ${response.data}');
      return handler.next(response);
    },
  ));

  // Add logging interceptor for debugging (optional - remove in production)
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
    logPrint: (obj) {
      // Only log in debug mode
      // print(obj);
    },
  ));

  return dio;
});