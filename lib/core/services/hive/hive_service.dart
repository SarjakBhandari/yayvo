import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/consumer/data/models/consumer_profile_cache_hive_model.dart';
import 'package:yayvo/features/consumer/data/models/product_cache_hive_model.dart';
import 'package:yayvo/features/consumer/data/models/review_cache_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);

    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.consumerTypeId)) {
      Hive.registerAdapter(ConsumerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.retailerTypeId)) {
      Hive.registerAdapter(RetailerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.userTypeId)) {
      Hive.registerAdapter(UserTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.reviewCacheTypeId)) {
      Hive.registerAdapter(ReviewCacheHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.productCacheTypeId)) {
      Hive.registerAdapter(ProductCacheHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.consumerProfileCacheTypeId)) {
      Hive.registerAdapter(ConsumerProfileCacheHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
    await Hive.openBox<ConsumerHiveModel>(HiveTableConstants.consumerTable);
    await Hive.openBox<RetailerHiveModel>(HiveTableConstants.retailerTable);
    await Hive.openBox<ReviewCacheHiveModel>(HiveTableConstants.reviewCacheTable);
    await Hive.openBox<ProductCacheHiveModel>(HiveTableConstants.productCacheTable);
    await Hive.openBox<ConsumerProfileCacheHiveModel>(
        HiveTableConstants.consumerProfileCacheTable);
    await Hive.openBox<String>(HiveTableConstants.collectionCacheTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> register(AuthHiveModel user) async {
    if (user.authId == null) {
      throw ArgumentError('authId must not be null for register');
    }
    await _authBox.put(user.authId, user);
    return user;
  }

  AuthHiveModel? login(String email, String passwordHash) {
    try {
      return _authBox.values.firstWhere((user) =>
      user.email == email && user.passwordHash == passwordHash);
    } catch (_) {
      return null;
    }
  }

  AuthHiveModel? getUserById(String authId, String role) {
    final user = _authBox.get(authId);
    if (user != null && user.role == role) {
      return user;
    }
    return null;
  }

  AuthHiveModel? getUserByEmail(String email, String role) {
    try {
      return _authBox.values
          .firstWhere((user) => user.role == role && user.email == email);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateUser(AuthHiveModel user) async {
    if (user.authId == null) return false;
    if (_authBox.containsKey(user.authId)) {
      final existing = _authBox.get(user.authId);
      if (existing != null && existing.role == user.role) {
        await _authBox.put(user.authId, user);
        return true;
      }
    }
    return false;
  }

  Future<void> deleteUser(String authId, String role) async {
    final user = _authBox.get(authId);
    if (user != null && user.role == role) {
      await _authBox.delete(authId);
    }
  }

  Box<ConsumerHiveModel> get _consumerBox =>
      Hive.box<ConsumerHiveModel>(HiveTableConstants.consumerTable);

  Future<ConsumerHiveModel> registerConsumer(ConsumerHiveModel consumer) async {
    if (consumer.authId == null) {
      throw ArgumentError('consumer.authId must not be null for registerConsumer');
    }
    await _consumerBox.put(consumer.authId, consumer);
    return consumer;
  }

  Future<bool> updateConsumer(ConsumerHiveModel consumer) async {
    if (consumer.authId == null) return false;
    if (_consumerBox.containsKey(consumer.authId)) {
      await _consumerBox.put(consumer.authId, consumer);
      return true;
    }
    return false;
  }

  ConsumerHiveModel? getConsumerById(String authId) =>
      _consumerBox.get(authId);

  List<ConsumerHiveModel> getAllConsumers() =>
      _consumerBox.values.toList();

  Box<RetailerHiveModel> get _retailerBox =>
      Hive.box<RetailerHiveModel>(HiveTableConstants.retailerTable);

  Future<RetailerHiveModel> registerRetailer(RetailerHiveModel retailer) async {
    if (retailer.authId == null) {
      throw ArgumentError('retailer.authId must not be null for registerRetailer');
    }
    await _retailerBox.put(retailer.authId, retailer);
    return retailer;
  }

  Future<bool> updateRetailer(RetailerHiveModel retailer) async {
    if (retailer.authId == null) return false;
    if (_retailerBox.containsKey(retailer.authId)) {
      await _retailerBox.put(retailer.authId, retailer);
      return true;
    }
    return false;
  }

  RetailerHiveModel? getRetailerById(String authId) =>
      _retailerBox.get(authId);

  List<RetailerHiveModel> getAllRetailers() => _retailerBox.values.toList();

  Box<ReviewCacheHiveModel> get _reviewCacheBox =>
      Hive.box<ReviewCacheHiveModel>(HiveTableConstants.reviewCacheTable);

  Future<void> saveReviewsCache(List<ReviewCacheHiveModel> list) async {
    await _reviewCacheBox.clear();
    for (final r in list) {
      await _reviewCacheBox.put(r.id, r);
    }
  }

  List<ReviewCacheHiveModel> getCachedReviews() {
    return _reviewCacheBox.values.toList();
  }

  Box<ProductCacheHiveModel> get _productCacheBox =>
      Hive.box<ProductCacheHiveModel>(HiveTableConstants.productCacheTable);

  Future<void> saveProductsCache(List<ProductCacheHiveModel> list) async {
    await _productCacheBox.clear();
    for (final p in list) {
      await _productCacheBox.put(p.id, p);
    }
  }

  List<ProductCacheHiveModel> getCachedProducts() {
    return _productCacheBox.values.toList();
  }

  Box<ConsumerProfileCacheHiveModel> get _consumerProfileCacheBox =>
      Hive.box<ConsumerProfileCacheHiveModel>(
          HiveTableConstants.consumerProfileCacheTable);

  ConsumerProfileCacheHiveModel? getConsumerProfileCache(String authId) =>
      _consumerProfileCacheBox.get(authId);

  Future<void> saveConsumerProfileCache(
      ConsumerProfileCacheHiveModel profile) async {
    await _consumerProfileCacheBox.put(profile.authId, profile);
  }

  static const String _keySavedReviews = 'saved_reviews_';
  static const String _keySavedProducts = 'saved_products_';

  Box<String> get _collectionCacheBox =>
      Hive.box<String>(HiveTableConstants.collectionCacheTable);

  Future<void> saveSavedReviewsCache(String authId, List<dynamic> reviewJsonList) async {
    await _collectionCacheBox.put(
      '$_keySavedReviews$authId',
      jsonEncode(reviewJsonList),
    );
  }

  List<Map<String, dynamic>> getSavedReviewsCache(String authId) {
    final raw = _collectionCacheBox.get('$_keySavedReviews$authId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSavedProductsCache(String authId, List<dynamic> productJsonList) async {
    await _collectionCacheBox.put(
      '$_keySavedProducts$authId',
      jsonEncode(productJsonList),
    );
  }

  List<Map<String, dynamic>> getSavedProductsCache(String authId) {
    final raw = _collectionCacheBox.get('$_keySavedProducts$authId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}