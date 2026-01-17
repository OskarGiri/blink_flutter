import 'package:blink_flutter/core/constants/api_endpoints.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_data_source.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  @override
  Future<String> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Validate response structure
        if (data == null) {
          throw Exception("Invalid login response from server");
        }

        final String token = data['token'];

        // Optional: debug user info
        final user = data['user'];
        debugPrint("Login successful");
        debugPrint("User ID: ${user?['id']}");
        debugPrint("User Email: ${user?['email']}");

        return token;
      } else {
        throw Exception(response.data?['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      debugPrint("DIO ERROR TYPE: ${e.type}");
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("RESPONSE DATA: ${e.response?.data}");

      final message =
          e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : 'Login failed. Please try again.';

      throw Exception(message);
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  @override
  Future<void> registerUser(AuthEntity user) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          "username": user.username,
          "email": user.email,
          "password": user.password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("Registration successful");
        return;
      } else {
        throw Exception(response.data?['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
