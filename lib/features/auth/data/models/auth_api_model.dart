import 'package:yayvo/features/auth/data/models/consumer_api_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
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

  factory AuthApiModel.fromEntity(
    AuthEntity authEntity,
    ConsumerEntity? consumerEntity,
  ) {
    return AuthApiModel(
      id: authEntity.authId,
      email: authEntity.email,
      password: authEntity.passwordHash,
      role: authEntity.role,
      consumer: consumerEntity != null
          ? ConsumerApiModel.fromConsumerEntity(consumerEntity)
          : null,
      token: null,
    );
  }

  /// Convert to JSON for sending to server.
  /// Omits password when null to avoid sending empty/undefined values.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (id != null && id!.isNotEmpty) map['id'] = id;
    map['email'] = email;
    map['role'] = role.name;

    if (consumer != null) {
      final consumerMap = Map<String, dynamic>.from(consumer!.toJson());
      // Ensure consumer map does not overwrite auth fields
      consumerMap.remove('email');
      consumerMap.remove('password');
      map.addAll(consumerMap);
    }

    // Always add auth password last to ensure it's not overwritten
    if (password != null && password!.isNotEmpty) map['password'] = password;

    return map;
  }

  /// Parse server response robustly. Accepts shapes:
  /// - { user: {...}, token: '...' }
  /// - { data: {...}, token: '...' }
  /// - flat user object { id/authId/_id, email, ... , token? }
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    // Normalize top-level shapes
    Map<String, dynamic> userMap = {};
    String? token;

    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
      token = json['token'] is String ? json['token'] as String : null;
    } else if (json.containsKey('data') &&
        json['data'] is Map<String, dynamic>) {
      userMap = Map<String, dynamic>.from(json['data'] as Map);
      token = json['token'] is String ? json['token'] as String : null;
    } else {
      // Treat json itself as user map if it contains user-like keys
      final hasUserKeys =
          json.containsKey('email') ||
          json.containsKey('id') ||
          json.containsKey('_id') ||
          json.containsKey('authId');
      if (hasUserKeys) {
        userMap = Map<String, dynamic>.from(json);
        token = json['token'] is String ? json['token'] as String : null;
      } else {
        // Fallback: empty map to avoid null errors
        userMap = <String, dynamic>{};
      }
    }

    // Parse consumer if present under different possible keys
    ConsumerApiModel? consumer;
    if (userMap.containsKey('consumer') &&
        userMap['consumer'] is Map<String, dynamic>) {
      consumer = ConsumerApiModel.fromJson(
        Map<String, dynamic>.from(userMap['consumer'] as Map),
      );
    } else if (userMap.containsKey('consumerData') &&
        userMap['consumerData'] is Map<String, dynamic>) {
      consumer = ConsumerApiModel.fromJson(
        Map<String, dynamic>.from(userMap['consumerData'] as Map),
      );
    }

    // Resolve id from common fields
    final id =
        (userMap['_id'] ?? userMap['id'] ?? userMap['authId']) as String?;

    // Resolve email safely
    final email = (userMap['email'] ?? '') as String;

    // Resolve role: if server returns role string, map to UserType; otherwise default to consumer
    UserType role = UserType.consumer;
    if (userMap.containsKey('role') && userMap['role'] is String) {
      final roleStr = (userMap['role'] as String).toLowerCase();
      if (roleStr.contains('retailer'))
        role = UserType.retailer;
      else if (roleStr.contains('admin'))
        role = UserType.admin;
      else
        role = UserType.consumer;
    }

    return AuthApiModel(
      id: id,
      email: email,
      password: null,
      role: role,
      consumer: consumer,
      token: token,
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

  AuthApiModel copyWith({
    String? id,
    String? email,
    String? password,
    String? token,
    UserType? role,
    ConsumerApiModel? consumer,
  }) {
    return AuthApiModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      role: role ?? this.role,
      consumer: consumer ?? this.consumer,
    );
  }
}
