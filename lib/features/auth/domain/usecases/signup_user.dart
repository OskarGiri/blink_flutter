
import 'package:blink_flutter/features/auth/data/models/user_model.dart';

import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<void> call(UserModel user) async {
    await repository.signup(user);
  }
}
