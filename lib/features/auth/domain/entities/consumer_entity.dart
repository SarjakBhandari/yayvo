import 'package:equatable/equatable.dart';

class ConsumerEntity extends Equatable {
  final String? authId;
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

  @override
  List<Object?> get props => [
    authId,
    fullName,
    username,
    phoneNumber,
    dob,
    gender,
    country,
    profilePicture,
  ];
}
