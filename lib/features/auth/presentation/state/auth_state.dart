import 'package:equatable/equatable.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';

/// Enum representing authentication status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}

/// Immutable state for authentication
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Copy state with updated values
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, errorMessage: $errorMessage)';
}