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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await signupUser(
      User(email: email, password: password),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await loginUser(email, password);

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  // Still OK for splash logic
  Future<bool> isLoggedIn() async {
    // this can be improved later using local datasource
    return true;
  }
}
