import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:blink_flutter/features/auth/presentation/view_moodel/auth_view_model.dart';
import '../../../../mocks/mock_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _TestAuthViewModel extends AuthViewModel {
  _TestAuthViewModel({
    this.initial = const AuthState(),
    this.loginStatus = AuthStatus.initial,
    this.loginMessage,
  });

  final AuthState initial;
  final AuthStatus loginStatus;
  final String? loginMessage;

  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  AuthState build() => initial;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;

    if (loginStatus == AuthStatus.loading) {
      state = state.copyWith(status: AuthStatus.loading);
      return;
    }

    if (loginStatus == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: loginMessage ?? 'mock login error',
      );
      return;
    }

    if (loginStatus == AuthStatus.authenticated) {
      state = state.copyWith(status: AuthStatus.authenticated);
      return;
    }
  }
}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

Future<void> _pumpLoginPage(
  WidgetTester tester, {
  required _TestAuthViewModel authViewModel,
  ProfileHiveModel? profile,
  String? currentUserId = 'user-1',
  _MockNavigatorObserver? observer,
}) async {
  final mockHive = MockHiveService();
  final mockSession = MockUserSessionService();

  when(() => mockSession.getCurrentUserId()).thenReturn(currentUserId);
  when(
    () => mockHive.getProfileByUserId(any()),
  ).thenAnswer((_) async => profile);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => authViewModel),
        hiveServiceProvider.overrideWithValue(mockHive),
        userSessionServiceProvider.overrideWithValue(mockSession),
      ],
      child: MaterialApp(
        home: const LoginPage(),
        navigatorObservers: observer == null ? const [] : [observer],
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('1. renders sign-in title text', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Sign in to continue to\nyour account'), findsOneWidget);
    });

    testWidgets('2. renders helper subtitle text', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(
        find.text('Enter your email & password to continue'),
        findsOneWidget,
      );
    });

    testWidgets('3. renders email input field', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('4. renders password input field', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('5. renders Continue button', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('6. renders forgot password action', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('7. renders sign-up link action', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('8. validates empty email', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('9. validates invalid email format', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid_email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('10. validates empty password', (tester) async {
      await _pumpLoginPage(tester, authViewModel: _TestAuthViewModel());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'john@example.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
