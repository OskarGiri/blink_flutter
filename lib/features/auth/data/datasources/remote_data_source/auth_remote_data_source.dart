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

// Provider
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
    debugPrint("🔥 LOGIN API CALL STARTED");
    debugPrint("📧 Login Email: $email");

    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      debugPrint("✅ LOGIN RESPONSE: ${response.statusCode}");
      debugPrint("📦 LOGIN DATA: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          throw Exception("Invalid login response from server");
        }

        final String token = data['token'];
        final userData = data['user'];

        // Save token
        await _tokenService.saveToken(token);

        if (userData != null) {
          final user = AuthApiModel.fromJson(userData);
          debugPrint("✅ Login successful");
          debugPrint("User ID: ${user.userId}");
          debugPrint("User Email: ${user.email}");
          return user;
        }

        return null;
      } else {
        throw Exception(response.data?['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      debugPrint("❌ LOGIN DIO ERROR TYPE: ${e.type}");
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("RESPONSE DATA: ${e.response?.data}");
      debugPrint("REQUEST OPTIONS: ${e.requestOptions}");

      final message =
          e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : 'Login failed. Please try again.';

      throw Exception(message);
    } catch (e) {
      debugPrint("❌ Login error: $e");
      throw Exception('An error occurred: $e');
    }
  }

  @override
  Future<AuthApiModel?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    debugPrint("🔥 === SIGNUP API CALL STARTED ===");
    debugPrint("🌐 BASE URL: ${_apiClient.dio.options.baseUrl}");
    debugPrint("📡 ENDPOINT: ${ApiEndpoints.register}");
    debugPrint("📧 Email: $email");
    debugPrint("👤 Username: $username");

    try {
      final requestData = {
        "username": username,
        "email": email,
        "password": password,
      };
      debugPrint("📤 REQUEST DATA: $requestData");

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      debugPrint("✅ API RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📦 API RESPONSE DATA: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        // Validate response structure
        if (data == null || data['user'] == null) {
          debugPrint("❌ Invalid response structure: ${data}");
          throw Exception("Invalid registration response from server");
        }

        // Parse user data (same structure as login)
        final userData = data['user'];
        final user = AuthApiModel.fromJson(userData);

        // Save token if returned by API
        if (data['token'] != null) {
          await _tokenService.saveToken(data['token']);
          debugPrint("🔑 Token saved");
        }

        debugPrint("✅ Registration successful!");
        debugPrint("👤 User ID: ${user.userId}");
        debugPrint("📧 User Email: ${user.email}");

        return user; // Return created user for local caching
      } else {
        final message = response.data?['message'] ?? 'Registration failed';
        debugPrint("❌ API returned error: $message");
        throw Exception(message);
      }
    } on DioException catch (e) {
      debugPrint("❌ === DIO EXCEPTION ===");
      debugPrint("TYPE: ${e.type}");
      debugPrint("MESSAGE: ${e.message}");
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("RESPONSE DATA: ${e.response?.data}");
      debugPrint("REQUEST URL: ${e.requestOptions.path}");
      debugPrint("REQUEST HEADERS: ${e.requestOptions.headers}");
      debugPrint("REQUEST DATA: ${e.requestOptions.data}");

      final message =
          e.response?.data?['message'] ??
          'Registration failed. Please try again.';
      throw Exception(message);
    } catch (e) {
      debugPrint("❌ Registration error: $e");
      throw Exception('An error occurred: $e');
    }
  }
}
