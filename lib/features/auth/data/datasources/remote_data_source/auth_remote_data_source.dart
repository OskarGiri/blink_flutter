import 'package:blink_flutter/core/api/api_client.dart';
import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_data_source.dart';
import 'package:blink_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create provider
final authRemoteDatasourceProvider = Provider<IAuthDataSource>((ref) {
  return AuthRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDataSource implements IAuthDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
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
        final userData = data['user'];

        // Save token
        await _tokenService.saveToken(token);

        // Parse user data into AuthApiModel
        if (userData != null) {
          final user = AuthApiModel.fromJson(userData);
          debugPrint("Login successful");
          debugPrint("User ID: ${user.userId}");
          debugPrint("User Email: ${user.email}");
          return user;
        }

        return null;
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
      final response = await _apiClient.post(
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
