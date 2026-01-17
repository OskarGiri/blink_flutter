import 'package:blink_flutter/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> signup(UserModel user);
  Future<UserModel?> login(String email, String password);
}
