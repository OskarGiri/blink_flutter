import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';

class AuthProvider extends ChangeNotifier {
  final SignupUser signupUser;
  final LoginUser loginUser;

  AuthProvider({
    required this.signupUser,
    required this.loginUser,
  });

  Future<void> signup(String email, String password) async {
    await signupUser(User(email: email, password: password));
  }

  Future<bool> login(String email, String password) async {
    final user = await loginUser(email, password);
    return user != null;
  }
}
