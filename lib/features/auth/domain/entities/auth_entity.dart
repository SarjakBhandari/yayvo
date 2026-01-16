import 'package:equatable/equatable.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'consumer_entity.dart';
import 'retailer_entity.dart';

class AuthEntity extends Equatable {
  final String? authId; // maps to Mongo _id
  final UserType role;  // "admin" | "consumer" | "retailer"
  final String email;
  final String passwordHash; // align with API

  final ConsumerEntity? consumer;
  final RetailerEntity? retailer;

  const AuthEntity({
    this.authId,
    required this.role,
    required this.email,
    required this.passwordHash,
    this.consumer,
    this.retailer,
  });

  AuthEntity copyWith({
    String? authId,
    UserType? role,
    String? email,
    String? passwordHash,
    ConsumerEntity? consumer,
    RetailerEntity? retailer,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      role: role ?? this.role,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      consumer: consumer ?? this.consumer,
      retailer: retailer ?? this.retailer,
    );
  }

  @override
  List<Object?> get props =>
      [authId, role, email, passwordHash, consumer, retailer];
}