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

class MockRegisterUser extends Mock implements RegisterUser {}

class MockLoginUser extends Mock implements LoginUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockGetUserById extends Mock implements GetUserById {}

class MockGetUserByEmail extends Mock implements GetUserByEmail {}

const tUser = AuthEntity(
  authId: 'auth123',
  role: UserType.consumer,
  email: 'jane@example.com',
  passwordHash: 'Hunter2!',
);

final tConsumer = ConsumerEntity(
  authId: 'auth123',
  fullName: 'Jane Doe',
  username: 'janedoe99',
  phoneNumber: '9800000000',
  dob: '1999-05-14',
  gender: 'female',
  country: 'Nepal',
);

const tApiError = ApiFailure(message: 'Something went wrong', statusCode: 500);

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
    registerFallbackValue(tUser);
    registerFallbackValue(tConsumer);
    registerFallbackValue(
      RegisterUserParams(authEntity: tUser, consumerEntity: tConsumer),
    );
    registerFallbackValue(
      const LoginParams(email: 'jane@example.com', passwordHash: 'Hunter2!'),
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

  test('starts with no user, no errors, and status set to initial', () {
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.initial);
    expect(state.user, isNull);
    expect(state.errorMessage, isNull);
  });

  test('goes into loading while a registration request is in flight', () async {
    when(() => mockRegisterUser.call(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 10));
      return const Right(tUser);
    });

    final future = container
        .read(authViewModelProvider.notifier)
        .register(tUser, tConsumer);
    expect(container.read(authViewModelProvider).status, AuthStatus.loading);
    await future;
  });

  test("becomes 'registered' after a successful sign-up", () async {
    when(
      () => mockRegisterUser.call(any()),
    ).thenAnswer((_) async => const Right(tUser));

    await container
        .read(authViewModelProvider.notifier)
        .register(tUser, tConsumer);

    expect(container.read(authViewModelProvider).status, AuthStatus.registered);
  });

  test('shows an error message when sign-up hits a conflict', () async {
    when(
      () => mockRegisterUser.call(any()),
    ).thenAnswer((_) async => const Left(tApiError));

    await container
        .read(authViewModelProvider.notifier)
        .register(tUser, tConsumer);

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, tApiError.message);
  });

  test(
    "becomes 'authenticated' and saves the user after a successful login",
    () async {
      when(
        () => mockLoginUser.call(any()),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'jane@example.com', password: 'Hunter2!');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUser);
    },
  );

  test('shows an error when login credentials are wrong', () async {
    const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
    when(
      () => mockLoginUser.call(any()),
    ).thenAnswer((_) async => const Left(failure));

    await container
        .read(authViewModelProvider.notifier)
        .login(email: 'jane@example.com', password: 'wrongpass');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Invalid credentials');
  });

  test(
    'restores the user session when getCurrentUser finds an active login',
    () async {
      when(
        () => mockGetCurrentUser.call(),
      ).thenAnswer((_) async => const Right(tUser));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUser);
    },
  );

  test('resolves and stores a user when fetching by id', () async {
    when(
      () => mockGetUserById.call(any()),
    ).thenAnswer((_) async => const Right(tUser));

    await container.read(authViewModelProvider.notifier).getUserById('auth123');

    expect(container.read(authViewModelProvider).user, tUser);
  });

  test('resolves and stores a user when fetching by email', () async {
    when(
      () => mockGetUserByEmail.call(any()),
    ).thenAnswer((_) async => const Right(tUser));

    await container
        .read(authViewModelProvider.notifier)
        .getUserByEmail('jane@example.com');

    expect(container.read(authViewModelProvider).user, tUser);
  });

  test('clears the error message when clearError is called', () async {
    when(
      () => mockRegisterUser.call(any()),
    ).thenAnswer((_) async => const Left(tApiError));
    await container
        .read(authViewModelProvider.notifier)
        .register(tUser, tConsumer);
    expect(container.read(authViewModelProvider).errorMessage, isNotNull);

    container.read(authViewModelProvider.notifier).clearError();

    expect(container.read(authViewModelProvider).errorMessage, isNull);
  });
}
