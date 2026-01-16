import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<void> signup(User user) async {
    // 1) API signup first
    await remoteDataSource.signup(email: user.email, password: user.password);

    // 2) Save locally (Hive) for offline use
    final userModel = UserModel(email: user.email, password: user.password);
    await localDataSource.signup(userModel);
  }

  @override
  Future<User?> login(String email, String password) async {
    // 1) API login first
    await remoteDataSource.login(email: email, password: password);

    // 2) Save locally (Hive)
    final userModel = UserModel(email: email, password: password);
    await localDataSource.signup(userModel);

    // 3) Return domain entity
    return userModel.toEntity();
  }
}
