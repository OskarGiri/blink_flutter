import 'package:flutter/material.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/login_user.dart' show LoginParams;

class AuthProvider extends ChangeNotifier {
  // final SignupUser signupUser;
  final LoginUseCase loginUseCase;

  AuthProvider({required this.loginUseCase});

  // Future<void> signup(String email, String password, String username) async {
  //   await signupUser(email, password, username);
  // }

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
}
