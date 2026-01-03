import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<void> signup(User user) async {
    final userModel = UserModel(email: user.email, password: user.password);
    await localDataSource.signup(userModel);
  }

  @override
  Future<User?> login(String email, String password) async {
    final userModel = localDataSource.login(email, password);
    return userModel?.toEntity();
  }
}
