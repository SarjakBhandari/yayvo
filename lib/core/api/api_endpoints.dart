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

  /// Consumer by auth id (login id).
  static String getConsumerByAuthId(String id) => '/api/consumers/auth/$id';
  /// Consumer by document _id (e.g. review authorId).
  static String getConsumerByDocId(String id) => '/api/consumers/$id';

  // ===== Reviews =====
  static const String reviewsCreate = '/api/reviews/';
  static String reviewImage(String id) => '/api/reviews/$id/image';
  static const String reviewsPaginated = '/api/reviews/paginated';
  static String reviewById(String id) => '/api/reviews/$id';
  static String reviewsByAuthor(String authorId) => '/api/reviews/author/$authorId';
  static String reviewLike(String id) => '/api/reviews/$id/like';
  static String reviewUnlike(String id) => '/api/reviews/$id/unlike';
  static String reviewIsLiked(String id, String userId) =>
      '/api/reviews/$id/islikedby/$userId';

  // ===== Products =====
  static const String productsPaginated = '/api/products';
  static String productById(String id) => '/api/products/$id';
  static const String productsLike = '/api/products/like';
  static const String productsUnlike = '/api/products/unlike';
  static const String productsIsLiked = '/api/products/isLiked';

  // ===== Collections =====
  static String savedReviews(String authId) =>
      '/api/collections/$authId/reviews';
  static String savedProducts(String authId) =>
      '/api/collections/$authId/products';
  static const String saveReview = '/api/collections/review/save';
  static const String unsaveReview = '/api/collections/review/unsave';
  static const String saveProduct = '/api/collections/product/save';
  static const String unsaveProduct = '/api/collections/product/unsave';
}