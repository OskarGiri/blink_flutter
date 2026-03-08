import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:blink_flutter/features/auth/presentation/view_moodel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthViewModel extends AuthViewModel {
  _TestAuthViewModel({
    this.initial = const AuthState(),
    this.signUpStatus = AuthStatus.initial,
    this.signUpMessage,
  });

  final AuthState initial;
  final AuthStatus signUpStatus;
  final String? signUpMessage;

  int signUpCalls = 0;
  String? lastUsername;
  String? lastEmail;
  String? lastPassword;

  @override
  AuthState build() => initial;

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastUsername = username;
    lastEmail = email;
    lastPassword = password;

    if (signUpStatus == AuthStatus.loading) {
      state = state.copyWith(status: AuthStatus.loading);
      return;
    }

    if (signUpStatus == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: signUpMessage ?? 'mock sign up error',
      );
      return;
    }

    if (signUpStatus == AuthStatus.created) {
      state = state.copyWith(status: AuthStatus.created);
      return;
    }
  }
}

Future<void> _pumpSignupPage(
  WidgetTester tester, {
  required _TestAuthViewModel authViewModel,
}) async {
  await tester.binding.setSurfaceSize(const Size(1080, 1920));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authViewModelProvider.overrideWith(() => authViewModel)],
      child: const MaterialApp(home: SignUpPage()),
    ),
  );
  await tester.pump();
}

void main() {
  group('SignUp Screen Widget Tests', () {
    testWidgets('1. renders CREATE ACCOUNT header', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('2. renders Join Blink subtitle', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Join Blink today'), findsOneWidget);
    });

    testWidgets('3. renders Username label', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('4. renders Email label', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('5. renders Password label', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('6. renders exactly three text fields', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('7. renders Sign Up button', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('8. renders login prompt text', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('9. tapping Login navigates to login page', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());

      await tester.ensureVisible(find.text('Login'));
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('10. username field accepts input', (tester) async {
      await _pumpSignupPage(tester, authViewModel: _TestAuthViewModel());

      await tester.enterText(find.byType(TextField).at(0), 'username_1');
      await tester.pump();

      expect(find.text('username_1'), findsOneWidget);
    });
  });
}
