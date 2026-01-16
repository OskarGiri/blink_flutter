import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(res.data);
  }
}
