import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_email_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_id_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/login_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/logout_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:yayvo/features/auth/presentation/state/auth_state.dart';

/// Provider for AuthViewModel
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

/// ViewModel handling authentication logic
class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUser _registerUsecase;
  late final LoginUser _loginUsecase;
  late final LogoutUser _logoutUsecase;
  late final GetCurrentUser _getCurrentUserUsecase;
  late final GetUserById _getUserByIdUsecase;
  late final GetUserByEmail _getUserByEmailUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUserProvider);
    _loginUsecase = ref.read(loginUserProvider);
    _logoutUsecase = ref.read(logoutUserProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserProvider);
    _getUserByIdUsecase = ref.read(getUserByIdProvider);
    _getUserByEmailUsecase = ref.read(getUserByEmailProvider);
    return const AuthState();
  }

  /// Register a new user
  Future<void> register(
    AuthEntity authEntity,
    ConsumerEntity consumerEntity,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterUserParams(
        authEntity: authEntity,
        consumerEntity: consumerEntity,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, passwordHash: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Get user by ID
  Future<void> getUserById(String authId) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getUserByIdUsecase(authId);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Get user by Email
  Future<void> getUserByEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getUserByEmailUsecase(email);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
