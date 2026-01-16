class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:5050/api';
  // For Android Emulator: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator: 'http://localhost:5000/api/v1'
  // For Physical Device: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String registrationConsumer = '/auth/register/consumer';
  static const String registrationRetailer = '/auth/register/retailer';
}