import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final Box box;
  AuthLocalDataSource(this.box);

  Future<void> signup(UserModel user) async {
    await box.put(user.email, user.password);
  }

  UserModel? login(String email, String password) {
    final stored = box.get(email);
    if (stored != null && stored == password) {
      return UserModel(email: email, password: password);
    }
    return null;
  }

  bool isLoggedIn() => box.isNotEmpty;
}
