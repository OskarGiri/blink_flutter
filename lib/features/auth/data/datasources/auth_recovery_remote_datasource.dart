import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';
import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/models/auth_recovery_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthRecoveryRemoteDataSource {
  Future<AuthRecoveryResponseModel> sendForgotPasswordOtp(String email);

  Future<AuthRecoveryResponseModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<AuthRecoveryResponseModel> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}

final authRecoveryRemoteDataSourceProvider =
    Provider<AuthRecoveryRemoteDataSource>((ref) {
      return AuthRecoveryRemoteDataSourceImpl(
        apiService: ref.read(apiServiceProvider),
      );
    });

class AuthRecoveryRemoteDataSourceImpl implements AuthRecoveryRemoteDataSource {
  final ApiService _apiService;

  AuthRecoveryRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<AuthRecoveryResponseModel> sendForgotPasswordOtp(String email) async {
    final response = await _apiService.post(ApiEndpoints.forgotPassword, {
      'email': email,
    });

    return AuthRecoveryResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<AuthRecoveryResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiService.post(ApiEndpoints.verifyOtp, {
      'email': email,
      'otp': otp,
    });

    return AuthRecoveryResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<AuthRecoveryResponseModel> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await _apiService.post(ApiEndpoints.resetPassword, {
      'email': email,
      'resetToken': resetToken,
      'newPassword': newPassword,
    });

    return AuthRecoveryResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
