import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'consumer_api_model.dart';

class AuthApiModel {
  final String? id;
  final String email;
  final String? password; // only used for registration
  final String? token;    // JWT token from login
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "password": password,
      if (consumer != null) "consumer": consumer!.toJson(),
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    // Case 1: Login response with "user" + "token"
    if (json.containsKey("user")) {
      final user = json["user"] as Map<String, dynamic>;
      return AuthApiModel(
        id: user["id"] as String?,
        email: user["email"] as String? ?? "",
        role: _mapRole(user["role"] as String? ?? "consumer"),
        token: json["token"] as String? ?? "",
      );
    }

    // Case 2: Registration response with "_id", "email", "password", "consumer"
    return AuthApiModel(
      id: json["_id"] as String?,
      email: json["email"] as String? ?? "",
      password: json["password"] as String?,
      role: UserType.consumer,
      consumer: json["consumer"] != null
          ? ConsumerApiModel.fromJson(json["consumer"] as Map<String, dynamic>)
          : null,
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

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      email: entity.email,
      password: entity.passwordHash,
      role: entity.role,
      consumer: entity.consumer != null
          ? ConsumerApiModel.fromEntity(entity.consumer!)
          : null,
    );
  }

  static UserType _mapRole(String role) {
    switch (role.toLowerCase()) {
      case "consumer":
        return UserType.consumer;
      case "admin":
        return UserType.admin;
      default:
        return UserType.consumer;
    }
  }
}