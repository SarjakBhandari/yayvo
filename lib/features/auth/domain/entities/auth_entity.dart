import 'package:equatable/equatable.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'consumer_entity.dart';
import 'retailer_entity.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final UserType userType;

  final String email;
  final String password;

  final ConsumerEntity? consumer;
  final RetailerEntity? retailer;

  const AuthEntity({
    this.authId,
    required this.userType,
    required this.email,
    required this.password,
    this.consumer,
    this.retailer,
  });

  @override
  List<Object?> get props => [authId, userType, email, password, consumer, retailer];
}
