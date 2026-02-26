import 'package:blink_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:blink_flutter/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  late final SignUpUsecase _signUpUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    // Initialize
    _signUpUsecase = ref.read(signUpUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);

    return AuthState();
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = SignUpUsecaseParams(
      username: username,
      email: email,
      password: password,
    );

    // wait for few seconds
    await Future.delayed(const Duration(seconds: 3));
    final result = await _signUpUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          message: 'Sign Up Failed: ${failure.message}',
        );
      },
      (user) {
        state = state.copyWith(status: AuthStatus.created);
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);

    // wait for few seconds
    await Future.delayed(const Duration(seconds: 3));
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          message: 'Login Failed: ${failure.message}',
        );
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated);
      },
    );
  }
}
