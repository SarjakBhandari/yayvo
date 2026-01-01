import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/core/services/hive/hive_service.dart';
import 'package:yayvo/features/auth/data/datasources/auth_datasource.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart'; // ✅ unified UserType

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    final savedAuth = await _hiveService.register(user);

    if (user.userTypeIndex == 0 && user.consumer != null) {
      await _hiveService.registerConsumer(user.consumer!);
    } else if (user.userTypeIndex == 1 && user.retailer != null) {
      await _hiveService.registerRetailer(user.retailer!);
    }

    return savedAuth;
  }

  @override
  Future<AuthHiveModel?> login(
      String email, String password, UserType userType) async {
    try {
      return _hiveService.login(
        email,
        password,
        userType == UserType.consumer ? 0 : 1,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId, UserType userType) async {
    try {
      return _hiveService.getUserById(
        authId,
        userType == UserType.consumer ? 0 : 1,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email, UserType userType) async {
    try {
      return _hiveService.getUserByEmail(
        email,
        userType == UserType.consumer ? 0 : 1,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      final updated = await _hiveService.updateUser(user);

      if (updated) {
        if (user.userTypeIndex == 0 && user.consumer != null) {
          await _hiveService.registerConsumer(user.consumer!);
        } else if (user.userTypeIndex == 1 && user.retailer != null) {
          await _hiveService.registerRetailer(user.retailer!);
        }
      }

      return updated;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId, UserType userType) async {
    try {
      await _hiveService.deleteUser(
        authId,
        userType == UserType.consumer ? 0 : 1,
      );

      if (userType == UserType.consumer) {
        final consumer = _hiveService.getConsumerById(authId);
        if (consumer != null) {
          await Hive.box<ConsumerHiveModel>(HiveTableConstants.consumerTable)
              .delete(authId);
        }
      } else {
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
          ? (user.userTypeIndex == 0 ? UserType.consumer : UserType.retailer)
          : null;
    } catch (_) {
      return null;
    }
  }
}
