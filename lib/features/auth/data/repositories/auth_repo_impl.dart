import 'package:blink_flutter/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  // Future<void> signup(UserModel user) async {
  //   await remoteDataSource.signup(email: user.email, password: user.password);
  //   await localDataSource.signup(
  //     UserModel(email: user.email, password: user.password, username: user.username),
  //   );
  // }
  @override
  Future<UserModel?> login(String email, String password) async {
    await remoteDataSource.login(email: email, password: password);

    final model = UserModel(
      email: email,
      password: password,
      username: username,
    );
    await localDataSource.signup(model);

    return model;
  }
}
