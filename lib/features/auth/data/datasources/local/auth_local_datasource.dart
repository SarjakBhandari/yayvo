import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/auth/data/datasources/auth_datasource.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  // ---------- Auth ----------
  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    final savedAuth = await _hiveService.register(user);

    if (user.role == UserType.consumer.name && user.consumer != null) {
      await _hiveService.registerConsumer(user.consumer!);
    } else if (user.role == UserType.retailer.name && user.retailer != null) {
      await _hiveService.registerRetailer(user.retailer!);
    }

    return savedAuth;
  }

  @override
  Future<AuthHiveModel?> login(
      String email,
      String passwordHash
      ) async {
    try {
      return _hiveService.login(email, passwordHash);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(
      String authId,
      UserType userType,
      ) async {
    try {
      return _hiveService.getUserById(authId, userType.name);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(
      String email,
      UserType userType,
      ) async {
    try {
      return _hiveService.getUserByEmail(email, userType.name);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      final updated = await _hiveService.updateUser(user);

      if (updated) {
        if (user.role == UserType.consumer.name && user.consumer != null) {
          await _hiveService.registerConsumer(user.consumer!);
        } else if (user.role == UserType.retailer.name && user.retailer != null) {
          await _hiveService.registerRetailer(user.retailer!);
        }
      }

      return updated;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(
      String authId,
      UserType userType,
      ) async {
    try {
      await _hiveService.deleteUser(authId, userType.name);

      if (userType == UserType.consumer) {
        final consumer = _hiveService.getConsumerById(authId);
        if (consumer != null) {
          await Hive.box<ConsumerHiveModel>(HiveTableConstants.consumerTable)
              .delete(authId);
        }
      } else if (userType == UserType.retailer) {
        final retailer = _hiveService.getRetailerById(authId);
        if (retailer != null) {
          await Hive.box<RetailerHiveModel>(HiveTableConstants.retailerTable)
              .delete(authId);
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final box = Hive.box<AuthHiveModel>(HiveTableConstants.authTable);
      return box.isNotEmpty ? box.values.first : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final box = Hive.box<AuthHiveModel>(HiveTableConstants.authTable);
      await box.clear();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserType?> getUserType(String authId) async {
    try {
      final box = Hive.box<AuthHiveModel>(HiveTableConstants.authTable);
      final user = box.get(authId);
      return user != null
          ? UserType.values.firstWhere((e) => e.name == user.role)
          : null;
    } catch (_) {
      return null;
    }
  }

  // ---------- Consumer ----------
  @override
  Future<ConsumerHiveModel> registerConsumer(ConsumerHiveModel consumer) async {
    return await _hiveService.registerConsumer(consumer);
  }

  @override
  ConsumerHiveModel? getConsumerById(String authId) {
    return _hiveService.getConsumerById(authId);
  }

  @override
  List<ConsumerHiveModel> getAllConsumers() {
    return _hiveService.getAllConsumers();
  }

  // ---------- Retailer ----------
  @override
  Future<RetailerHiveModel> registerRetailer(RetailerHiveModel retailer) async {
    return await _hiveService.registerRetailer(retailer);
  }

  @override
  RetailerHiveModel? getRetailerById(String authId) {
    return _hiveService.getRetailerById(authId);
  }

  @override
  List<RetailerHiveModel> getAllRetailers() {
    return _hiveService.getAllRetailers();
  }
}