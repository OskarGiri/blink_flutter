import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<void> call(User user) async {
    await repository.signup(user);
  }
}
