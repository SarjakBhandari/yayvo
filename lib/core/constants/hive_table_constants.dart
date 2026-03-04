class HiveTableConstants {
  HiveTableConstants._();

  // ======================= Database =========================
  static const String dbName = 'yayvo_db';

  // ======================= Auth =========================
  static const int authTypeId = 1;
  static const String authTable = 'auth_table';

  // ======================= Consumer =========================
  static const int consumerTypeId = 2;
  static const String consumerTable = 'consumer_table';

  // ======================= Retailer =========================
  static const int retailerTypeId = 3;
  static const String retailerTable = 'retailer_table';

  // ======================= UserType Enum =========================
  static const int userTypeId = 4; // adapter for UserType enum

  // ======================= Consumer feature cache =========================
  static const int reviewCacheTypeId = 5;
  static const String reviewCacheTable = 'review_cache_table';
  static const int productCacheTypeId = 6;
  static const String productCacheTable = 'product_cache_table';
  static const int consumerProfileCacheTypeId = 7;
  static const String consumerProfileCacheTable = 'consumer_profile_cache_table';

  static const String collectionCacheTable = 'collection_cache_table';
}
