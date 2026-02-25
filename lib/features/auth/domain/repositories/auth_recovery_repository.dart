import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/features/auth/domain/entities/reset_token_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class AuthRecoveryRepository {
  Future<Either<Failure, String>> sendForgotPasswordOtp(String email);

  Future<Either<Failure, ResetTokenEntity>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
