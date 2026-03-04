import '../../domain/entities/consumer_entity.dart';

class ConsumerApiModel {
  final String? id;
  final String? authId;
  final String displayName;
  final String? username;
  final String? bio;
  final String? profilePicture;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? country;

  ConsumerApiModel({
    this.id,
    this.authId,
    required this.displayName,
    this.username,
    this.bio,
    this.profilePicture,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.country,
  });

  factory ConsumerApiModel.fromJson(Map<String, dynamic> json) {
    final displayName = (json['displayName'] as String?) ??
        (json['fullName'] as String?) ??
        (json['username'] as String?) ??
        '';
    return ConsumerApiModel(
      id: json['_id'] as String?,
      authId: json['authId'] as String? ?? json['_id'] as String?,
      displayName: displayName,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (authId != null) 'authId': authId,
      'displayName': displayName,
      if (username != null) 'username': username,
      'bio': bio,
      'profilePicture': profilePicture,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (country != null) 'country': country,
    };
  }

  ConsumerEntity toEntity() {
    return ConsumerEntity(
      id: id,
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

  factory ConsumerApiModel.fromEntity(ConsumerEntity e) {
    return ConsumerApiModel(
      id: e.id,
      authId: e.authId,
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
