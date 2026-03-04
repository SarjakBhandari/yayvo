import 'package:hive/hive.dart';
import 'package:yayvo/core/constants/hive_table_constants.dart';
import 'package:yayvo/features/consumer/domain/entities/consumer_entity.dart';

@HiveType(typeId: HiveTableConstants.consumerProfileCacheTypeId)
class ConsumerProfileCacheHiveModel extends HiveObject {
  @HiveField(0)
  final String authId;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final String? bio;

  @HiveField(3)
  final String? profilePicture;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? dob;

  @HiveField(7)
  final String? gender;

  @HiveField(8)
  final String? country;

  ConsumerProfileCacheHiveModel({
    required this.authId,
    required this.displayName,
    this.bio,
    this.profilePicture,
    this.username,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.country,
  });

  ConsumerEntity toEntity() {
    return ConsumerEntity(
      authId: authId,
      displayName: displayName,
      username: username,
      bio: bio,
      profilePicture: profilePicture,
      phoneNumber: phoneNumber,
      dob: dob,
      gender: gender,
      country: country,
    );
  }

  static ConsumerProfileCacheHiveModel fromEntity(ConsumerEntity e) {
    return ConsumerProfileCacheHiveModel(
      authId: e.authId ?? '',
      displayName: e.displayName,
      username: e.username,
      bio: e.bio,
      profilePicture: e.profilePicture,
      phoneNumber: e.phoneNumber,
      dob: e.dob,
      gender: e.gender,
      country: e.country,
    );
  }
}

class ConsumerProfileCacheHiveModelAdapter
    extends TypeAdapter<ConsumerProfileCacheHiveModel> {
  @override
  final int typeId = HiveTableConstants.consumerProfileCacheTypeId;

  @override
  ConsumerProfileCacheHiveModel read(BinaryReader reader) {
    final authId = reader.read() as String;
    final displayName = reader.read() as String;
    final bio = reader.read() as String?;
    final profilePicture = reader.read() as String?;
    String? username;
    String? phoneNumber;
    String? dob;
    String? gender;
    String? country;
    try {
      username = reader.read() as String?;
      phoneNumber = reader.read() as String?;
      dob = reader.read() as String?;
      gender = reader.read() as String?;
      country = reader.read() as String?;
    } catch (_) {}
    return ConsumerProfileCacheHiveModel(
      authId: authId,
      displayName: displayName,
      bio: bio,
      profilePicture: profilePicture,
      username: username,
      phoneNumber: phoneNumber,
      dob: dob,
      gender: gender,
      country: country,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumerProfileCacheHiveModel obj) {
    writer.write(obj.authId);
    writer.write(obj.displayName);
    writer.write(obj.bio);
    writer.write(obj.profilePicture);
    writer.write(obj.username);
    writer.write(obj.phoneNumber);
    writer.write(obj.dob);
    writer.write(obj.gender);
    writer.write(obj.country);
  }
}
