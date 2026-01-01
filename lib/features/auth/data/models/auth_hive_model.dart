import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.phoneNumber,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
    );
  }
}
