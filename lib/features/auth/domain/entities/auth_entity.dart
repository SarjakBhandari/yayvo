import 'package:equatable/equatable.dart';
import 'consumer_entity.dart';
import 'retailer_entity.dart';

enum UserType { consumer, retailer }

class AuthEntity extends Equatable {
  final String? authId;
  final UserType userType;
  final ConsumerEntity? consumer;
  final RetailerEntity? retailer;

  const AuthEntity({
    this.authId,
    required this.userType,
    this.consumer,
    this.retailer,
  });

  @override
  List<Object?> get props => [authId, userType, consumer, retailer];
}
