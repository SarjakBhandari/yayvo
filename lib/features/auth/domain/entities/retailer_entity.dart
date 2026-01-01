import 'package:equatable/equatable.dart';

class RetailerEntity extends Equatable {
  final String? authId;
  final String ownerName;
  final String organizationName;
  final String username;
  final String? phoneNumber;
  final String? dateOfEstablishment;
  final String? country;
  final String? profilePicture;

  const RetailerEntity({
    this.authId,
    required this.ownerName,
    required this.organizationName,
    required this.username,
    this.phoneNumber,
    this.dateOfEstablishment,
    this.country,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    ownerName,
    organizationName,
    username,
    phoneNumber,
    dateOfEstablishment,
    country,
    profilePicture,
  ];
}
