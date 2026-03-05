import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/domain/repositories/auth_repository.dart';
import 'package:yayvo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_email_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/get_user_by_id_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/login_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/logout_user_usecase.dart';
import 'package:yayvo/features/auth/domain/usecases/register_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

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

void main() {
  late MockAuthRepository repo;

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

  setUp(() => repo = MockAuthRepository());

  group('RegisterUser', () {
    test('a new user can register with valid details', () async {
      when(
        () => repo.register(any(), any()),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await RegisterUser(repo)(
        RegisterUserParams(authEntity: tUser, consumerEntity: tConsumer),
      );

      expect(result, const Right(tUser));
      verify(() => repo.register(tUser, tConsumer)).called(1);
    });

    test('registration fails when the email is already taken', () async {
      const failure = ApiFailure(
        message: 'Email already in use',
        statusCode: 409,
      );
      when(
        () => repo.register(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await RegisterUser(repo)(
        RegisterUserParams(authEntity: tUser, consumerEntity: tConsumer),
      );

      expect(result, const Left(failure));
    });
  });

  group('LoginUser', () {
    test('a registered user can log in with correct credentials', () async {
      when(
        () => repo.login(any(), any()),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await LoginUser(repo)(
        const LoginParams(email: 'jane@example.com', passwordHash: 'Hunter2!'),
      );

      expect(result, const Right(tUser));
      verify(() => repo.login('jane@example.com', 'Hunter2!')).called(1);
    });

    test('login returns an error for the wrong password', () async {
      const failure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(
        () => repo.login(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await LoginUser(repo)(
        const LoginParams(email: 'jane@example.com', passwordHash: 'wrongpass'),
      );

      expect(result, const Left(failure));
    });
  });

  group('LogoutUser', () {
    test('logging out returns true and calls the repo once', () async {
      when(() => repo.logout()).thenAnswer((_) async => const Right(true));

      final result = await LogoutUser(repo)();

      expect(result, const Right(true));
      verify(() => repo.logout()).called(1);
    });

    test(
      'logout returns a failure if the session could not be cleared',
      () async {
        const failure = LocalDatabaseFailure(
          message: 'Failed to clear session',
        );
        when(() => repo.logout()).thenAnswer((_) async => const Left(failure));

        final result = await LogoutUser(repo)();

        expect(result, const Left(failure));
      },
    );
  });

  group('GetCurrentUser', () {
    test('returns the logged-in user when a session is active', () async {
      when(
        () => repo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await GetCurrentUser(repo)();

      expect(result, const Right(tUser));
    });

    test('returns an error when there is no active session', () async {
      const failure = ApiFailure(message: 'No active session', statusCode: 401);
      when(
        () => repo.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await GetCurrentUser(repo)();

      expect(result, const Left(failure));
    });
  });

  group('GetUserById', () {
    test('finds a user by their auth id', () async {
      when(
        () => repo.getUserById(any()),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await GetUserById(repo)('auth123');

      expect(result, const Right(tUser));
      verify(() => repo.getUserById('auth123')).called(1);
    });
  });

  group('GetUserByEmail', () {
    test('finds a user by their email address', () async {
      when(
        () => repo.getUserByEmail(any()),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await GetUserByEmail(repo)('jane@example.com');

      expect(result, const Right(tUser));
      verify(() => repo.getUserByEmail('jane@example.com')).called(1);
    });
  });
}
