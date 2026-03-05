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

void main() {
  late MockAuthRepository mockRepo;

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
    mockRepo = MockAuthRepository();
  });

  // ─── RegisterUser ─────────────────────────────────────────────────────────
  group('RegisterUser', () {
    test('returns AuthEntity on successful registration', () async {
      when(
        () => mockRepo.register(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = RegisterUser(mockRepo);
      final result = await usecase(
        RegisterUserParams(
          authEntity: tAuthEntity,
          consumerEntity: tConsumerEntity,
        ),
      );

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepo.register(tAuthEntity, tConsumerEntity)).called(1);
    });

    test('returns ApiFailure when email already exists (409)', () async {
      const failure = ApiFailure(
        message: 'Email already in use',
        statusCode: 409,
      );
      when(
        () => mockRepo.register(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = RegisterUser(mockRepo);
      final result = await usecase(
        RegisterUserParams(
          authEntity: tAuthEntity,
          consumerEntity: tConsumerEntity,
        ),
      );

      expect(result, const Left(failure));
    });

    test('returns ApiFailure on network error', () async {
      const failure = ApiFailure(
        message: 'No internet connection',
        statusCode: null,
      );
      when(
        () => mockRepo.register(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = RegisterUser(mockRepo);
      final result = await usecase(
        RegisterUserParams(
          authEntity: tAuthEntity,
          consumerEntity: tConsumerEntity,
        ),
      );

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'No internet connection'),
        (_) => fail('should be Left'),
      );
    });
  });

  // ─── LoginUser ────────────────────────────────────────────────────────────
  group('LoginUser', () {
    test('returns AuthEntity on successful login', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = LoginUser(mockRepo);
      final result = await usecase(
        const LoginParams(
          email: 'test@example.com',
          passwordHash: 'Password1!',
        ),
      );

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepo.login('test@example.com', 'Password1!')).called(1);
    });

    test('returns ApiFailure on wrong password (401)', () async {
      const failure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = LoginUser(mockRepo);
      final result = await usecase(
        const LoginParams(email: 'test@example.com', passwordHash: 'wrongpass'),
      );

      expect(result, const Left(failure));
    });

    test('returns ApiFailure when user does not exist (404)', () async {
      const failure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = LoginUser(mockRepo);
      final result = await usecase(
        const LoginParams(email: 'ghost@example.com', passwordHash: 'pass123'),
      );

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'User not found'),
        (_) => fail('should be Left'),
      );
    });
  });

  // ─── LogoutUser ───────────────────────────────────────────────────────────
  group('LogoutUser', () {
    test('returns true on successful logout', () async {
      when(() => mockRepo.logout()).thenAnswer((_) async => const Right(true));

      final usecase = LogoutUser(mockRepo);
      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockRepo.logout()).called(1);
    });

    test('returns LocalDatabaseFailure when session clearance fails', () async {
      const failure = LocalDatabaseFailure(message: 'Failed to clear session');
      when(
        () => mockRepo.logout(),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = LogoutUser(mockRepo);
      final result = await usecase();

      expect(result, const Left(failure));
    });
  });

  // ─── GetCurrentUser ───────────────────────────────────────────────────────
  group('GetCurrentUser', () {
    test('returns AuthEntity when session is active', () async {
      when(
        () => mockRepo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetCurrentUser(mockRepo);
      final result = await usecase();

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepo.getCurrentUser()).called(1);
    });

    test('returns ApiFailure when no session exists (401)', () async {
      const failure = ApiFailure(message: 'No active session', statusCode: 401);
      when(
        () => mockRepo.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = GetCurrentUser(mockRepo);
      final result = await usecase();

      expect(result, const Left(failure));
    });

    test('delegates directly to repository without transformation', () async {
      when(
        () => mockRepo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetCurrentUser(mockRepo);
      await usecase();

      verify(() => mockRepo.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });

  // ─── GetUserById ──────────────────────────────────────────────────────────
  group('GetUserById', () {
    test('returns AuthEntity when user exists', () async {
      when(
        () => mockRepo.getUserById(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetUserById(mockRepo);
      final result = await usecase('auth123');

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepo.getUserById('auth123')).called(1);
    });

    test('returns ApiFailure when user not found (404)', () async {
      const failure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockRepo.getUserById(any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = GetUserById(mockRepo);
      final result = await usecase('nonexistent-id');

      expect(result, const Left(failure));
    });

    test('passes the exact authId string to the repository', () async {
      when(
        () => mockRepo.getUserById(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetUserById(mockRepo);
      await usecase('specific-auth-id-abc');

      verify(() => mockRepo.getUserById('specific-auth-id-abc')).called(1);
    });
  });

  // ─── GetUserByEmail ───────────────────────────────────────────────────────
  group('GetUserByEmail', () {
    test('returns AuthEntity when email matches a registered user', () async {
      when(
        () => mockRepo.getUserByEmail(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetUserByEmail(mockRepo);
      final result = await usecase('test@example.com');

      expect(result, const Right(tAuthEntity));
      verify(() => mockRepo.getUserByEmail('test@example.com')).called(1);
    });

    test('returns ApiFailure when email has no matching user (404)', () async {
      const failure = ApiFailure(message: 'User not found', statusCode: 404);
      when(
        () => mockRepo.getUserByEmail(any()),
      ).thenAnswer((_) async => const Left(failure));

      final usecase = GetUserByEmail(mockRepo);
      final result = await usecase('notfound@example.com');

      expect(result, const Left(failure));
    });

    test('passes the exact email string to the repository', () async {
      when(
        () => mockRepo.getUserByEmail(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final usecase = GetUserByEmail(mockRepo);
      await usecase('exact@email.com');

      verify(() => mockRepo.getUserByEmail('exact@email.com')).called(1);
    });
  });
}
