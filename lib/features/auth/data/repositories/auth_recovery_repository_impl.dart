import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_recovery_remote_datasource.dart';
import 'package:blink_flutter/features/auth/domain/entities/reset_token_entity.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_recovery_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRecoveryRepositoryProvider = Provider<AuthRecoveryRepository>((ref) {
  return AuthRecoveryRepositoryImpl(
    remoteDataSource: ref.read(authRecoveryRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRecoveryRepositoryImpl implements AuthRecoveryRepository {
  final AuthRecoveryRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRecoveryRepositoryImpl({
    required AuthRecoveryRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, String>> sendForgotPasswordOtp(String email) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return const Left(
        ApiFailure(message: 'No internet. Password reset requires internet.'),
      );
    }

    try {
      final result = await _remoteDataSource.sendForgotPasswordOtp(email);
      return Right(result.message);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallbackMessage: 'Failed to send OTP'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResetTokenEntity>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return const Left(
        ApiFailure(message: 'No internet. Password reset requires internet.'),
      );
    }

    try {
      final result = await _remoteDataSource.verifyOtp(email: email, otp: otp);

      final token = (result.resetToken ?? '').trim();
      if (token.isEmpty) {
        return const Left(ApiFailure(message: 'Reset token missing'));
      }

      return Right(ResetTokenEntity(resetToken: token));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e, fallbackMessage: 'Failed to verify OTP'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return const Left(
        ApiFailure(message: 'No internet. Password reset requires internet.'),
      );
    }

    try {
      final result = await _remoteDataSource.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return Right(result.message);
    } on DioException catch (e) {
      return Left(
        _mapDioFailure(e, fallbackMessage: 'Failed to reset password'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  ApiFailure _mapDioFailure(DioException e, {required String fallbackMessage}) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return ApiFailure(
        message: data['message'].toString(),
        statusCode: e.response?.statusCode,
      );
    }

    return ApiFailure(
      message: e.message ?? fallbackMessage,
      statusCode: e.response?.statusCode,
    );
  }
}
