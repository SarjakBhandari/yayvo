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

  /// store userType as int (0 = consumer, 1 = retailer)
  @HiveField(1)
  final int userTypeIndex;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final ConsumerHiveModel? consumer;

  @HiveField(5)
  final RetailerHiveModel? retailer;

  AuthHiveModel({
    String? authId,
    required this.userTypeIndex,
    required this.email,
    required this.password,
    this.consumer,
    this.retailer,
  }) : authId = authId ?? const Uuid().v4();

  // ✅ Convert to domain entity
  AuthEntity toEntity() {
    final type = userTypeIndex == 0 ? UserType.consumer : UserType.retailer;
    return AuthEntity(
      authId: authId,
      userType: type,
      email: email,
      password: password,
      consumer: consumer?.toEntity(),
      retailer: retailer?.toEntity(),
    );
  }


  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      userTypeIndex: entity.userType == UserType.consumer ? 0 : 1,
      email: entity.email,
      password: entity.password,
      consumer: entity.consumer != null
          ? ConsumerHiveModel.fromEntity(entity.consumer!)
          : null,
      retailer: entity.retailer != null
          ? RetailerHiveModel.fromEntity(entity.retailer!)
          : null,
    );
  }
}
