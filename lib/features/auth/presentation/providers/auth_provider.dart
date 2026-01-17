import 'package:flutter/material.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/login_user.dart' show LoginParams;
import '../../domain/usecases/signup_user.dart' show SignupParams;

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final SignupUser signupUser;

  AuthProvider({required this.loginUseCase, required this.signupUser});

  /// LOGIN
  Future<bool> login(String email, String password) async {
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        debugPrint("Login failed: ${failure.message}");
        return false;
      },
      (token) {
        debugPrint("Login success, token: $token");
        return true;
      },
    );
  }

  /// SIGNUP
  Future<bool> signup(String username, String email, String password) async {
    final result = await signupUser(
      SignupParams(username: username, email: email, password: password),
    );

    return result.fold(
      (failure) {
        debugPrint("Signup failed: ${failure.message}");
        return false;
      },
      (_) {
        debugPrint("Signup successful");
        return true;
      },
    );
  }
}
