// consumer_api_model.dart
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

class ConsumerApiModel {
  final String? authId;
  final String email;
  final String password;
  final String fullName;
  final String username;
  final String phoneNumber;
  final String dob;
  final String gender;
  final String country;
  final String? profilePicture;

  ConsumerApiModel({
    this.authId,
    required this.email,
    required this.password,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.dob,
    required this.gender,
    required this.country,
    this.profilePicture,
  });

  factory ConsumerApiModel.fromEntity(AuthEntity auth, ConsumerEntity consumer) {
    return ConsumerApiModel(
      authId: auth.authId,
      email: auth.email,
      password: auth.passwordHash,
      fullName: consumer.fullName,
      username: consumer.username,
      phoneNumber: consumer.phoneNumber ?? '',
      dob: consumer.dob ?? '',
      gender: consumer.gender ?? '',
      country: consumer.country ?? '',
      profilePicture: consumer.profilePicture,
    );
  }

  factory ConsumerApiModel.fromConsumerEntity(ConsumerEntity consumer) {
    return ConsumerApiModel(
      authId: consumer.authId,
      email: '',
      password: '',
      fullName: consumer.fullName,
      username: consumer.username,
      phoneNumber: consumer.phoneNumber ?? '',
      dob: consumer.dob ?? '',
      gender: consumer.gender ?? '',
      country: consumer.country ?? '',
      profilePicture: consumer.profilePicture,
    );
  }

  factory ConsumerApiModel.fromJson(Map<String, dynamic> json) {
    return ConsumerApiModel(
      authId: (json['authId'] as String?) ?? (json['_id'] as String?),
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      dob: (json['dob'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (authId != null) map['authId'] = authId;
    if (email.isNotEmpty) map['email'] = email;
    if (password.isNotEmpty) map['password'] = password;

    map['fullName'] = fullName;
    map['username'] = username;
    map['phoneNumber'] = phoneNumber;
    map['dob'] = dob;
    map['gender'] = gender;
    map['country'] = country;
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      map['profilePicture'] = profilePicture;
    }
    return map;
  }

  ConsumerEntity toEntity() {
    return ConsumerEntity(
      authId: authId,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      dob: dob.isEmpty ? null : dob,
      gender: gender.isEmpty ? null : gender,
      country: country.isEmpty ? null : country,
      profilePicture: profilePicture,
    );
  }
}