// core/api/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - FIXED: Removed typo (space, dash, and extra parenthesis)
  static const String baseUrl = 'http://10.0.2.2:5050';

  // Environment-specific URLs:
  // For Android Emulator: 'http://10.0.2.2:5050'
  // For iOS Simulator: 'http://localhost:5050'
  // For Physical Device: 'http://192.168.x.x:5050' (replace with your IP)

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ===== Auth endpoints =====
  static const String login = '/api/auth/login';
  static const String registrationConsumer = '/api/auth/register/consumer';
  static const String registrationRetailer = '/api/auth/register/retailer';

  // ===== Consumer endpoints =====
  static String updateConsumerProfilePicture(String id) =>
      '/api/consumers/$id/profile-picture';

  static String updateConsumer(String id) => '/api/consumers/$id';

  static String getConsumerById(String id) => '/api/consumers/auth/$id';
}