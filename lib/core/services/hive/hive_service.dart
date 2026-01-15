import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

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
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
    await Hive.openBox<ConsumerHiveModel>(HiveTableConstants.consumerTable);
    await Hive.openBox<RetailerHiveModel>(HiveTableConstants.retailerTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  AuthHiveModel? login(String email, String passwordHash) {
    try {
      return _authBox.values.firstWhere((user) =>
          user.email == email &&
          user.passwordHash == passwordHash);
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
    await _consumerBox.put(consumer.authId, consumer);
    return consumer;
  }

  ConsumerHiveModel? getConsumerById(String authId) =>
      _consumerBox.get(authId);

  List<ConsumerHiveModel> getAllConsumers() =>
      _consumerBox.values.toList();

  Box<RetailerHiveModel> get _retailerBox =>
      Hive.box<RetailerHiveModel>(HiveTableConstants.retailerTable);

  Future<RetailerHiveModel> registerRetailer(RetailerHiveModel retailer) async {
    await _retailerBox.put(retailer.authId, retailer);
    return retailer;
  }

  RetailerHiveModel? getRetailerById(String authId) =>
      _retailerBox.get(authId);

  List<RetailerHiveModel> getAllRetailers() =>
      _retailerBox.values.toList();
}