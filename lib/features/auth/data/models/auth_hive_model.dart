import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/data/models/consumer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/retailer_hive_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final ConsumerHiveModel? consumer;

  @HiveField(5)
  final RetailerHiveModel? retailer;

  AuthHiveModel({
    String? authId,
    required this.role,
    required this.email,
    required this.passwordHash,
    this.consumer,
    this.retailer,
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity() {
    final userType = UserType.values.firstWhere((e) => e.name == role);
    return AuthEntity(
      authId: authId,
      role: userType,
      email: email,
      passwordHash: passwordHash,
      consumer: consumer?.toEntity(),
      retailer: retailer?.toEntity(),
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      role: entity.role.name,
      email: entity.email,
      passwordHash: entity.passwordHash,
      consumer: entity.consumer != null
          ? ConsumerHiveModel.fromEntity(entity.consumer!)
          : null,
      retailer: entity.retailer != null
          ? RetailerHiveModel.fromEntity(entity.retailer!)
          : null,
    );
  }
}
