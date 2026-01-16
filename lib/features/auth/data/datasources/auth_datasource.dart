import 'package:yayvo/features/auth/data/models/auth_api_model.dart';
import 'package:yayvo/features/auth/data/models/auth_hive_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_api_model.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

abstract interface class IAuthLocalDataSource {
  // ---------- Auth ----------
  Future<AuthHiveModel> register(AuthHiveModel user);

  Future<AuthHiveModel?> login(
      String email,
      String passwordHash,
      );

  Future<AuthHiveModel?> getUserById(String authId, UserType userType);

  Future<AuthHiveModel?> getUserByEmail(String email, UserType userType);

  Future<bool> updateUser(AuthHiveModel user);

  Future<bool> deleteUser(String authId, UserType userType);

  Future<AuthHiveModel?> getCurrentUser();

  Future<bool> logout();

  Future<UserType?> getUserType(String authId);

  // ---------- Consumer ----------
  Future<ConsumerHiveModel> registerConsumer(ConsumerHiveModel consumer);

  ConsumerHiveModel? getConsumerById(String authId);

  List<ConsumerHiveModel> getAllConsumers();

  // ---------- Retailer ----------
  Future<RetailerHiveModel> registerRetailer(RetailerHiveModel retailer);

  RetailerHiveModel? getRetailerById(String authId);

  List<RetailerHiveModel> getAllRetailers();
}


abstract interface class IAuthRemoteDataSource {
  // ---------- Auth ----------
  Future<AuthApiModel> register(AuthApiModel user);

  Future<AuthApiModel?> login(
      String email,
      String passwordHash,
      );

  Future<AuthApiModel?> getUserById(String authId, UserType userType);

  Future<AuthApiModel?> getUserByEmail(String email, UserType userType);

  Future<bool> updateUser(AuthApiModel user);

  Future<bool> deleteUser(String authId, UserType userType);

  Future<AuthApiModel?> getCurrentUser();

  Future<bool> logout();

  Future<UserType?> getUserType(String authId);

  // ---------- Consumer ----------
  Future<ConsumerApiModel> registerConsumer(ConsumerApiModel consumer);

  Future<ConsumerApiModel?> getConsumerById(String authId);

  Future<List<ConsumerApiModel>> getAllConsumers();
}
