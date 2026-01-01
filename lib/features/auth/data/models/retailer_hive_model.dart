import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/auth/domain/entities/retailer_entity.dart';

part 'retailer_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.retailerTypeId)
class RetailerHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String ownerName;

  @HiveField(2)
  final String organizationName;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String? phoneNumber;

  @HiveField(5)
  final String? dateOfEstablishment;

  @HiveField(6)
  final String? country;

  @HiveField(7)
  final String? profilePicture;

  RetailerHiveModel({
    String? authId,
    required this.ownerName,
    required this.organizationName,
    required this.username,
    this.phoneNumber,
    this.dateOfEstablishment,
    this.country,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  RetailerEntity toEntity() {
    return RetailerEntity(
      authId: authId,
      ownerName: ownerName,
      organizationName: organizationName,
      username: username,
      phoneNumber: phoneNumber,
      dateOfEstablishment: dateOfEstablishment,
      country: country,
      profilePicture: profilePicture,
    );
  }

  factory RetailerHiveModel.fromEntity(RetailerEntity entity) {
    return RetailerHiveModel(
      authId: entity.authId,
      ownerName: entity.ownerName,
      organizationName: entity.organizationName,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      dateOfEstablishment: entity.dateOfEstablishment,
      country: entity.country,
      profilePicture: entity.profilePicture,
    );
  }
}
