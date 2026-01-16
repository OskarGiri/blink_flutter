import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    await dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }
}
