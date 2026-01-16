// auth_api_model.dart
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'consumer_api_model.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

class AuthApiModel {
  final String? id;
  final String email;
  final String? password;
  final String? token;
  final UserType role;
  final ConsumerApiModel? consumer;

  AuthApiModel({
    this.id,
    required this.email,
    this.password,
    this.token,
    required this.role,
    this.consumer,
  });

  factory AuthApiModel.fromEntity(AuthEntity authEntity, ConsumerEntity? consumerEntity) {
    return AuthApiModel(
      id: authEntity.authId,
      email: authEntity.email,
      password: authEntity.passwordHash,
      role: authEntity.role,
      consumer: consumerEntity != null ? ConsumerApiModel.fromConsumerEntity(consumerEntity) : null,
      token: null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      if (id != null) 'id': id,
      'email': email,
      'password': password,
      'role': role.name,
    };

    if (consumer != null) {
      final consumerMap = Map<String, dynamic>.from(consumer!.toJson());
      consumerMap.remove('email');
      consumerMap.remove('password');
      map.addAll(consumerMap);
    }

    return map;
  }
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("user")) {
      final user = json["user"] as Map<String, dynamic>;
      return AuthApiModel(
        id: user["id"] as String?,
        email: user["email"] as String? ?? "",
        role: _mapRole(user["role"] as String? ?? "consumer"),
        token: json["token"] as String? ?? "",
        password: null,
        consumer: null,
      );
    }

    ConsumerApiModel? consumer;
    if (json.containsKey("consumer") && json["consumer"] is Map<String, dynamic>) {
      consumer = ConsumerApiModel.fromJson(json["consumer"] as Map<String, dynamic>);
    } else {
      final hasConsumerFields = json.containsKey("fullName") || json.containsKey("username");
      if (hasConsumerFields) consumer = ConsumerApiModel.fromJson(json);
    }

    return AuthApiModel(
      id: (json["_id"] ?? json["id"]) as String?,
      email: json["email"] as String? ?? "",
      password: json["password"] as String?,
      role: UserType.consumer,
      consumer: consumer,
      token: null,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      email: email,
      role: role,
      passwordHash: password ?? '',
      consumer: consumer?.toEntity(),
    );
  }

  static UserType _mapRole(String role) {
    switch (role.toLowerCase()) {
      case "consumer":
        return UserType.consumer;
      case "admin":
        return UserType.admin;
      case "retailer":
        return UserType.retailer;
      default:
        return UserType.consumer;
    }
  }
}