import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> signup(User user);
  Future<User?> login(String email, String password);
}
