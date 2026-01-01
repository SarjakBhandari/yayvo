import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/usecases/logout.dart';
import 'package:yayvo/features/auth/domain/usecases/register_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_id_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_email_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_type_usecase.dart';
import 'package:yayvo/features/auth/presentation/state/auth_state.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import '../../domain/usecases/login_usecase.dart';

/// Provider for AuthViewModel
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

/// ViewModel handling authentication logic
class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final GetUserByIdUsecase _getUserByIdUsecase;
  late final GetUserByEmailUsecase _getUserByEmailUsecase;
  late final GetUserTypeUsecase _getUserTypeUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _getUserByIdUsecase = ref.read(getUserByIdUsecaseProvider);
    _getUserByEmailUsecase = ref.read(getUserByEmailUsecaseProvider);
    _getUserTypeUsecase = ref.read(getUserTypeUsecaseProvider);
    return const AuthState();
  }

  /// Register a new user
  Future<void> register(AuthEntity user) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(RegisterParams(user));

    result.fold(
          (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
          (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  /// Login existing user
  Future<void> login({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password, userType: userType),
    );

    result.fold(
          (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
          (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
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
          (_) => state = state.copyWith(status: AuthStatus.unauthenticated, user: null),
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
          (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
