import 'package:equatable/equatable.dart';

class ConsumerEntity extends Equatable {
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

  const ConsumerEntity({
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

  ConsumerEntity copyWith({
    String? id,
    String? authId,
    String? displayName,
    String? username,
    String? bio,
    String? profilePicture,
    String? phoneNumber,
    String? dob,
    String? gender,
    String? country,
  }) {
    return ConsumerEntity(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props =>
      [id, authId, displayName, username, bio, profilePicture, phoneNumber, dob, gender, country];
}
