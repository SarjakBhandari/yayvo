import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

part 'consumer_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.consumerTypeId)
class ConsumerHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? dob;

  @HiveField(5)
  final String? gender;

  @HiveField(6)
  final String? country;

  @HiveField(7)
  final String? profilePicture;

  ConsumerHiveModel({
    String? authId,
    required this.fullName,
    required this.username,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.country,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  ConsumerEntity toEntity() {
    return ConsumerEntity(
      authId: authId,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      dob: dob,
      gender: gender,
      country: country,
      profilePicture: profilePicture,
    );
  }

  factory ConsumerHiveModel.fromEntity(ConsumerEntity entity) {
    return ConsumerHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      dob: entity.dob,
      gender: entity.gender,
      country: entity.country,
      profilePicture: entity.profilePicture,
    );
  }
}
