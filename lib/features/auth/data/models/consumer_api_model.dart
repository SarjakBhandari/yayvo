import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

class ConsumerApiModel {
  final String id; // maps to authId
  final String fullName;
  final String username;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? country;
  final String? profilePicture;

  ConsumerApiModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.country,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "username": username,
      "phoneNumber": phoneNumber ?? "",
      "dob": dob ?? "",
      "gender": gender ?? "",
      "country": country ?? "",
      "profilePicture": profilePicture ?? "",
    };
  }

  factory ConsumerApiModel.fromJson(Map<String, dynamic> json) {
    return ConsumerApiModel(
      // handle both "id" and "_id"
      id: (json["id"] ?? json["_id"] ?? "") as String,
      fullName: (json["fullName"] ?? "") as String,
      username: (json["username"] ?? "") as String,
      phoneNumber: json["phoneNumber"] as String?,
      dob: json["dob"] as String?,
      gender: json["gender"] as String?,
      country: json["country"] as String?,
      profilePicture: json["profilePicture"] as String?,
    );
  }

  ConsumerEntity toEntity() {
    return ConsumerEntity(
      authId: id,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      dob: dob,
      gender: gender,
      country: country,
      profilePicture: profilePicture,
    );
  }

  factory ConsumerApiModel.fromEntity(ConsumerEntity entity) {
    return ConsumerApiModel(
      id: entity.authId ?? "",
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