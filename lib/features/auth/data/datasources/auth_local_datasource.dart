import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final Box<UserModel> box;

  AuthLocalDataSource(this.box);

  Future<void> signup(UserModel user) async {
    await box.put(user.email, user);
  }

  UserModel? login(String email, String password) {
    final user = box.get(email);
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }
}
