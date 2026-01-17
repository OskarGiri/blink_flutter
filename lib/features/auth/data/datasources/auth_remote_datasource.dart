import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<void> signup({required String email, required String password}) async {
    try {
      print(" SIGNUP -> https://reqres.in/api/register");

      final res = await dio.post(
        'https://reqres.in/api/register',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print(" SIGNUP STATUS: ${res.statusCode}");
      print(" SIGNUP DATA: ${res.data}");
    } on DioException catch (e) {
      print(" DIO TYPE: ${e.type}");
      print(" DIO MSG: ${e.message}");
      print(" DIO STATUS: ${e.response?.statusCode}");
      print(" DIO DATA: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      print(" LOGIN -> https://reqres.in/api/login");

      final res = await dio.post(
        'https://reqres.in/api/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print(" LOGIN STATUS: ${res.statusCode}");
      print(" LOGIN DATA: ${res.data}");
    } on DioException catch (e) {
      print(" DIO TYPE: ${e.type}");
      print(" DIO MSG: ${e.message}");
      print(" DIO STATUS: ${e.response?.statusCode}");
      print(" DIO DATA: ${e.response?.data}");
      rethrow;
    }
  }
}
