import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:blink_flutter/features/auth/domain/usecases/login_usecase.dart';
import '../../../../mocks/mock_auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  group('LoginUsecase', () {
    final successCases = <({String email, String password, AuthEntity entity})>[
      (
        email: 'john@example.com',
        password: 'password123',
        entity: const AuthEntity(
          userId: 'u1',
          username: 'john',
          email: 'john@example.com',
          password: 'password123',
        ),
      ),
      (
        email: 'jane@example.com',
        password: 'qwerty12',
        entity: const AuthEntity(
          userId: 'u2',
          username: 'jane',
          email: 'jane@example.com',
          password: 'qwerty12',
        ),
      ),
      (
        email: 'a@b.co',
        password: 'shortok',
        entity: const AuthEntity(
          userId: 'u3',
          username: 'ab',
          email: 'a@b.co',
          password: 'shortok',
        ),
      ),
      (
        email: 'caps@EXAMPLE.COM',
        password: 'Case1234',
        entity: const AuthEntity(
          userId: 'u4',
          username: 'caps',
          email: 'caps@EXAMPLE.COM',
          password: 'Case1234',
        ),
      ),
      (
        email: 'plus+tag@mail.com',
        password: 'complex!@#',
        entity: const AuthEntity(
          userId: 'u5',
          username: 'plus',
          email: 'plus+tag@mail.com',
          password: 'complex!@#',
        ),
      ),
      (
        email: 'num123@mail.com',
        password: '12345678',
        entity: const AuthEntity(
          userId: 'u6',
          username: 'num123',
          email: 'num123@mail.com',
          password: '12345678',
        ),
      ),
      (
        email: 'underscore_name@mail.com',
        password: 'pass_word_1',
        entity: const AuthEntity(
          userId: 'u7',
          username: 'underscore_name',
          email: 'underscore_name@mail.com',
          password: 'pass_word_1',
        ),
      ),
      (
        email: 'dot.name@mail.com',
        password: 'dot.pass',
        entity: const AuthEntity(
          userId: 'u8',
          username: 'dotname',
          email: 'dot.name@mail.com',
          password: 'dot.pass',
        ),
      ),
      (
        email: 'long.email.address@domain.io',
        password: 'VeryLongPassword123456',
        entity: const AuthEntity(
          userId: 'u9',
          username: 'longmail',
          email: 'long.email.address@domain.io',
          password: 'VeryLongPassword123456',
        ),
      ),
      (
        email: 'user@localhost.dev',
        password: 'devpass99',
        entity: const AuthEntity(
          userId: 'u10',
          username: 'local',
          email: 'user@localhost.dev',
          password: 'devpass99',
        ),
      ),
    ];

    for (final tc in successCases) {
      test('returns Right on success for ${tc.email}', () async {
        // Arrange
        when(
          () => mockRepository.login(tc.email, tc.password),
        ).thenAnswer((_) async => Right(tc.entity));

        // Act
        final result = await usecase(
          LoginUsecaseParams(email: tc.email, password: tc.password),
        );

        // Assert
        expect(result, Right<Failure, AuthEntity>(tc.entity));
        verify(() => mockRepository.login(tc.email, tc.password)).called(1);
      });
    }

    final failureCases = <({String email, String password, Failure failure})>[
      (
        email: 'wrong@example.com',
        password: 'wrong',
        failure: const ApiFailure(
          message: 'Invalid credentials',
          statusCode: 401,
        ),
      ),
      (
        email: 'server@down.com',
        password: 'password',
        failure: const ApiFailure(message: 'Server error', statusCode: 500),
      ),
      (
        email: 'offline@user.com',
        password: 'offline123',
        failure: const LocalDatabaseFailure(message: 'User not found'),
      ),
      (
        email: 'offline2@user.com',
        password: 'wrongpass',
        failure: const LocalDatabaseFailure(message: 'Incorrect password'),
      ),
      (
        email: 'network@lost.com',
        password: 'abc12345',
        failure: const ApiFailure(message: 'No internet', statusCode: 0),
      ),
      (
        email: 'timeout@api.com',
        password: 'abc12345',
        failure: const ApiFailure(message: 'Request timeout', statusCode: 408),
      ),
      (
        email: 'locked@user.com',
        password: 'abc12345',
        failure: const ApiFailure(message: 'Account locked', statusCode: 423),
      ),
      (
        email: 'ratelimit@user.com',
        password: 'abc12345',
        failure: const ApiFailure(
          message: 'Too many requests',
          statusCode: 429,
        ),
      ),
    ];

    for (final tc in failureCases) {
      test('returns Left failure for ${tc.email}', () async {
        // Arrange
        when(
          () => mockRepository.login(tc.email, tc.password),
        ).thenAnswer((_) async => Left(tc.failure));

        // Act
        final result = await usecase(
          LoginUsecaseParams(email: tc.email, password: tc.password),
        );

        // Assert
        expect(result, Left<Failure, AuthEntity>(tc.failure));
        verify(() => mockRepository.login(tc.email, tc.password)).called(1);
      });
    }

    final edgeCases = <({String email, String password, Failure failure})>[
      (
        email: '',
        password: 'password123',
        failure: const ApiFailure(
          message: 'Email is required',
          statusCode: 400,
        ),
      ),
      (
        email: 'missing-password@example.com',
        password: '',
        failure: const ApiFailure(
          message: 'Password is required',
          statusCode: 400,
        ),
      ),
      (
        email: '',
        password: '',
        failure: const ApiFailure(message: 'Invalid payload', statusCode: 400),
      ),
      (
        email: '   ',
        password: '    ',
        failure: const ApiFailure(message: 'Whitespace only', statusCode: 400),
      ),
      (
        email: 'null-like@example.com',
        password: 'null-like',
        failure: const ApiFailure(
          message: 'Null response from server',
          statusCode: 502,
        ),
      ),
      (
        email: 'emoji@example.com',
        password: 'pass🙂',
        failure: const ApiFailure(
          message: 'Unsupported characters',
          statusCode: 422,
        ),
      ),
    ];

    for (final tc in edgeCases) {
      test('handles edge input case for email="${tc.email}"', () async {
        // Arrange
        when(
          () => mockRepository.login(tc.email, tc.password),
        ).thenAnswer((_) async => Left(tc.failure));

        // Act
        final result = await usecase(
          LoginUsecaseParams(email: tc.email, password: tc.password),
        );

        // Assert
        expect(result, Left<Failure, AuthEntity>(tc.failure));
        verify(() => mockRepository.login(tc.email, tc.password)).called(1);
      });
    }

    final exceptionCases = <({String email, String password, String message})>[
      (
        email: 'throw1@example.com',
        password: '123456',
        message: 'unexpected exception',
      ),
      (
        email: 'throw2@example.com',
        password: 'abcdef',
        message: 'socket exception',
      ),
      (
        email: 'throw3@example.com',
        password: 'qwerty',
        message: 'format exception',
      ),
      (
        email: 'throw4@example.com',
        password: 'zxcvbn',
        message: 'type exception',
      ),
    ];

    for (final tc in exceptionCases) {
      test('rethrows repository exception: ${tc.message}', () async {
        // Arrange
        when(
          () => mockRepository.login(tc.email, tc.password),
        ).thenThrow(Exception(tc.message));

        // Act + Assert
        expect(
          () => usecase(
            LoginUsecaseParams(email: tc.email, password: tc.password),
          ),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.login(tc.email, tc.password)).called(1);
      });
    }

    test('calls repository twice when usecase is called twice', () async {
      // Arrange
      const email = 'double@example.com';
      const password = 'double-pass';
      const entity = AuthEntity(
        userId: 'double',
        username: 'double',
        email: email,
        password: password,
      );
      when(
        () => mockRepository.login(email, password),
      ).thenAnswer((_) async => const Right(entity));

      // Act
      await usecase(const LoginUsecaseParams(email: email, password: password));
      await usecase(const LoginUsecaseParams(email: email, password: password));

      // Assert
      verify(() => mockRepository.login(email, password)).called(2);
    });

    test('forwards exact values without mutation', () async {
      // Arrange
      const email = '  keep-space@example.com  ';
      const password = '  keep-space-pass  ';
      const entity = AuthEntity(
        userId: 'raw',
        username: 'raw-user',
        email: email,
        password: password,
      );
      when(
        () => mockRepository.login(email, password),
      ).thenAnswer((_) async => const Right(entity));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: email, password: password),
      );

      // Assert
      expect(result, const Right<Failure, AuthEntity>(entity));
      verify(() => mockRepository.login(email, password)).called(1);
    });
  });
}
