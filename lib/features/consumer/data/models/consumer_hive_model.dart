import '../../domain/entities/consumer_entity.dart';

/// Local model for consumer profile (API shape). Not used with Hive in this module.
class ConsumerHiveModel {
  final String authId;
  final String displayName;
  final String? bio;
  final String? profilePicture;
  final String? username;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? country;

  ConsumerHiveModel({
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
      bio: bio,
      profilePicture: profilePicture,
      username: username,
      phoneNumber: phoneNumber,
      dob: dob,
      gender: gender,
      country: country,
    );
  }

  factory ConsumerHiveModel.fromEntity(ConsumerEntity e) {
    return ConsumerHiveModel(
      authId: e.authId ?? '',
      displayName: e.displayName,
      bio: e.bio,
      profilePicture: e.profilePicture,
      username: e.username,
      phoneNumber: e.phoneNumber,
      dob: e.dob,
      gender: e.gender,
      country: e.country,
    );
  }
}
