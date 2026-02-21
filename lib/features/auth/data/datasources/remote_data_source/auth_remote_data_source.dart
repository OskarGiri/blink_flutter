

import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/core/network/api_service.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_data_source.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<IAuthDataSource>((ref) {
  return AuthRemoteDataSource(
    apiService: ref.read(apiServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
    hiveService: ref.read(hiveServiceProvider),
    profileRemote: ref.read(profileRemoteDatasourceProvider),
  );
});

class AuthRemoteDataSource implements IAuthDataSource {
  final ApiService _apiService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  final HiveService _hive;
  final ProfileRemoteDatasource _profileRemote;

  AuthRemoteDataSource({
    required ApiService apiService,
    required UserSessionService userSessionService,
    required TokenService tokenService,
    required HiveService hiveService,
    required ProfileRemoteDatasource profileRemote,
  })  : _apiService = apiService,
        _userSessionService = userSessionService,
        _tokenService = tokenService,
        _hive = hiveService,
        _profileRemote = profileRemote;

  Future<void> _cacheMeToHive(String userId) async {
    final me = await _profileRemote.getMe(); // already normalizes photos if you used my earlier version
    final photos = (me["photos"] is List)
        ? (me["photos"] as List).map((e) => e.toString()).toList()
        : <String>[];

    final profile = ProfileHiveModel(
      userId: userId,
      fullName: (me["fullName"] ?? "").toString(),
      dob: (me["dob"] ?? "").toString(),
      gender: (me["gender"] ?? "").toString(),
      lookingFor: (me["lookingFor"] ?? "").toString(),
      photos: photos,
      pendingSync: false,
    );

    await _hive.saveProfile(profile);
  }

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    debugPrint("🔥 LOGIN API CALL STARTED");
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'];
        final userData = data['user'];

        await _tokenService.saveToken(token);

        if (userData != null) {
          final user = AuthApiModel.fromJson(Map<String, dynamic>.from(userData));

          await _userSessionService.saveUserSession(
            userId: user.userId!,
            email: user.email,
            fullName: "",
            username: user.username,
          );

          // ✅ NEW: auto-fetch /users/me and cache to Hive so Dashboard shows name/age/photos
          await _cacheMeToHive(user.userId!);

          return user;
        }
      }

      throw Exception(response.data?['message'] ?? 'Login failed');
    } on DioException catch (e) {
      final message = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message']
          : 'Login failed. Please try again.';
      throw Exception(message);
    }
  }

  @override
  Future<AuthApiModel?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.register,
        data: {"username": username, "email": email, "password": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        final user = AuthApiModel.fromJson(Map<String, dynamic>.from(data['user']));

        if (data['token'] != null) {
          await _tokenService.saveToken(data['token']);
        }

        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          fullName: "",
          username: user.username,
        );

        // optional: cache me after signup too
        await _cacheMeToHive(user.userId!);

        return user;
      }

      throw Exception(response.data?['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      final message = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message']
          : 'Registration failed. Please try again.';
      throw Exception(message);
    }
  }
}