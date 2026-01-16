import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final Box box;
  AuthLocalDataSource(this.box);

  Future<void> signup(UserModel user) async {
    await box.put(user.email, user.password);
  }

  UserModel? login(String email, String password) {
    final storedPassword = box.get(email);
    if (storedPassword != null && storedPassword == password) {
      return UserModel(email: email, password: password);
    }
    return null;
  }
}
