import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_email_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_id_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/login_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/logout_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:yayvo/features/auth/presentation/state/auth_state.dart';
import 'package:yayvo/features/auth/presentation/view_model/auth_viewmodel.dart';

// ─── Mock use cases ───────────────────────────────────────────────────────
class MockRegisterUser extends Mock implements RegisterUser {}

class MockLoginUser extends Mock implements LoginUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockGetUserById extends Mock implements GetUserById {}

class MockGetUserByEmail extends Mock implements GetUserByEmail {}

// ─── Shared fixtures ──────────────────────────────────────────────────────
const tAuthEntity = AuthEntity(
  authId: 'auth123',
  role: UserType.consumer,
  email: 'test@example.com',
  passwordHash: 'Password1!',
);

final tConsumerEntity = ConsumerEntity(
  authId: 'auth123',
  fullName: 'Test User',
  username: 'testuser1234',
  phoneNumber: '9800000000',
  dob: '2000-01-01',
  gender: 'male',
  country: 'Nepal',
);

const tApiFailure = ApiFailure(
  message: 'Something went wrong',
  statusCode: 500,
);

// ─── Helper ───────────────────────────────────────────────────────────────
ProviderContainer _buildContainer({
  required MockRegisterUser registerUser,
  required MockLoginUser loginUser,
  required MockLogoutUser logoutUser,
  required MockGetCurrentUser getCurrentUser,
  required MockGetUserById getUserById,
  required MockGetUserByEmail getUserByEmail,
}) {
  return ProviderContainer(
    overrides: [
      registerUserProvider.overrideWithValue(registerUser),
      loginUserProvider.overrideWithValue(loginUser),
      logoutUserProvider.overrideWithValue(logoutUser),
      getCurrentUserProvider.overrideWithValue(getCurrentUser),
      getUserByIdProvider.overrideWithValue(getUserById),
      getUserByEmailProvider.overrideWithValue(getUserByEmail),
    ],
  );
}

void main() {
  late MockRegisterUser mockRegisterUser;
  late MockLoginUser mockLoginUser;
  late MockLogoutUser mockLogoutUser;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockGetUserById mockGetUserById;
  late MockGetUserByEmail mockGetUserByEmail;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(tAuthEntity);
    registerFallbackValue(tConsumerEntity);
    registerFallbackValue(
      RegisterUserParams(
        authEntity: tAuthEntity,
        consumerEntity: tConsumerEntity,
      ),
    );
    registerFallbackValue(
      const LoginParams(email: 'test@example.com', passwordHash: 'Password1!'),
    );
  });

  setUp(() {
    mockRegisterUser = MockRegisterUser();
    mockLoginUser = MockLoginUser();
    mockLogoutUser = MockLogoutUser();
    mockGetCurrentUser = MockGetCurrentUser();
    mockGetUserById = MockGetUserById();
    mockGetUserByEmail = MockGetUserByEmail();

    container = _buildContainer(
      registerUser: mockRegisterUser,
      loginUser: mockLoginUser,
      logoutUser: mockLogoutUser,
      getCurrentUser: mockGetCurrentUser,
      getUserById: mockGetUserById,
      getUserByEmail: mockGetUserByEmail,
    );
  });

  tearDown(() => container.dispose());

  // ─── Initial state ───────────────────────────────────────────────────────
  group('initial state', () {
    test('status is AuthStatus.initial on creation', () {
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
    });

    test('user is null on creation', () {
      final state = container.read(authViewModelProvider);
      expect(state.user, isNull);
    });

    test('errorMessage is null on creation', () {
      final state = container.read(authViewModelProvider);
      expect(state.errorMessage, isNull);
    });
  });

  // ─── register() ──────────────────────────────────────────────────────────
  group('register()', () {
    test('sets status to loading before result arrives', () async {
      // Use a completer so we can observe the loading state
      when(() => mockRegisterUser.call(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return const Right(tAuthEntity);
      });

      final notifier = container.read(authViewModelProvider.notifier);
      final future = notifier.register(tAuthEntity, tConsumerEntity);

      // Immediately after calling, state should be loading
      expect(container.read(authViewModelProvider).status, AuthStatus.loading);
      await future;
    });

    test('sets status to registered on success', () async {
      when(
        () => mockRegisterUser.call(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await container
          .read(authViewModelProvider.notifier)
          .register(tAuthEntity, tConsumerEntity);

      expect(
        container.read(authViewModelProvider).status,
        AuthStatus.registered,
      );
    });

    test('sets status to error and stores message on failure', () async {
      when(
        () => mockRegisterUser.call(any()),
      ).thenAnswer((_) async => const Left(tApiFailure));

      await container
          .read(authViewModelProvider.notifier)
          .register(tAuthEntity, tConsumerEntity);

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, tApiFailure.message);
    });
  });

  // ─── login() ─────────────────────────────────────────────────────────────
  group('login()', () {
    test('sets status to loading before result arrives', () async {
      when(() => mockLoginUser.call(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return const Right(tAuthEntity);
      });

      final notifier = container.read(authViewModelProvider.notifier);
      final future = notifier.login(
        email: 'test@example.com',
        password: 'Password1!',
      );

      expect(container.read(authViewModelProvider).status, AuthStatus.loading);
      await future;
    });

    test('sets status to authenticated and stores user on success', () async {
      when(
        () => mockLoginUser.call(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'test@example.com', password: 'Password1!');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
    });

    test(
      'sets status to error and stores message on wrong credentials',
      () async {
        const failure = ApiFailure(
          message: 'Invalid credentials',
          statusCode: 401,
        );
        when(
          () => mockLoginUser.call(any()),
        ).thenAnswer((_) async => const Left(failure));

        await container
            .read(authViewModelProvider.notifier)
            .login(email: 'test@example.com', password: 'wrongpass');

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
      },
    );
  });

  // ─── logout() ────────────────────────────────────────────────────────────
  group('logout()', () {
    test('sets status to unauthenticated and clears user on success', () async {
      when(
        () => mockLogoutUser.call(),
      ).thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });

    test('sets status to error on logout failure', () async {
      const failure = LocalDatabaseFailure(message: 'Failed to clear session');
      when(
        () => mockLogoutUser.call(),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Failed to clear session');
    });
  });

  // ─── getCurrentUser() ────────────────────────────────────────────────────
  group('getCurrentUser()', () {
    test('sets status to authenticated and stores user on success', () async {
      when(
        () => mockGetCurrentUser.call(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
    });

    test('sets status to error when no session exists', () async {
      const failure = ApiFailure(message: 'No active session', statusCode: 401);
      when(
        () => mockGetCurrentUser.call(),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No active session');
    });
  });

  // ─── getUserById() ───────────────────────────────────────────────────────
  group('getUserById()', () {
    test('sets status to authenticated and stores user on success', () async {
      when(
        () => mockGetUserById.call(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await container
          .read(authViewModelProvider.notifier)
          .getUserById('auth123');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
    });

    test('sets status to error when user id not found', () async {
      const failure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockGetUserById.call(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .getUserById('bad-id');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'User not found');
    });
  });

  // ─── getUserByEmail() ────────────────────────────────────────────────────
  group('getUserByEmail()', () {
    test('sets status to authenticated and stores user on success', () async {
      when(
        () => mockGetUserByEmail.call(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      await container
          .read(authViewModelProvider.notifier)
          .getUserByEmail('test@example.com');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
    });

    test('sets status to error when email not found', () async {
      const failure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockGetUserByEmail.call(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .getUserByEmail('ghost@example.com');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'User not found');
    });
  });

  // ─── clearError() ────────────────────────────────────────────────────────
  group('clearError()', () {
    test('resets errorMessage to null', () async {
      when(
        () => mockLoginUser.call(any()),
      ).thenAnswer((_) async => const Left(tApiFailure));
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'test@example.com', password: 'wrongpass');
      // Error is set
      expect(
        container.read(authViewModelProvider).errorMessage,
        tApiFailure.message,
      );

      // Clear it
      container.read(authViewModelProvider.notifier).clearError();

      expect(container.read(authViewModelProvider).errorMessage, isNull);
    });

    test('does not change status when clearing error', () async {
      when(
        () => mockLoginUser.call(any()),
      ).thenAnswer((_) async => const Left(tApiFailure));
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'test@example.com', password: 'wrongpass');

      container.read(authViewModelProvider.notifier).clearError();

      // Status remains error, only message is cleared
      expect(container.read(authViewModelProvider).status, AuthStatus.error);
    });
  });
}
