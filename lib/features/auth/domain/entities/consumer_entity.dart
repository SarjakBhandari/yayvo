import 'package:equatable/equatable.dart';

class ConsumerEntity extends Equatable {
  final String? authId; // foreign key to User
  final String fullName;
  final String username;
  final String? phoneNumber;
  final String? dob;
  final String? gender;
  final String? country;
  final String? profilePicture;

  const ConsumerEntity({
    this.authId,
    required this.fullName,
    required this.username,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.country,
    this.profilePicture,
  });

  ConsumerEntity copyWith({
    String? authId,
    String? fullName,
    String? username,
    String? phoneNumber,
    String? dob,
    String? gender,
    String? country,
    String? profilePicture,
  }) {
    return ConsumerEntity(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props =>
      [authId, fullName, username, phoneNumber, dob, gender, country, profilePicture];
}