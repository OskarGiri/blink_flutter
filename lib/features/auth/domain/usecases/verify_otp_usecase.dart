import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_recovery_repository_impl.dart';
import 'package:blink_flutter/features/auth/domain/entities/reset_token_entity.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_recovery_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

final verifyOtpUsecaseProvider = Provider<VerifyOtpUsecase>((ref) {
  return VerifyOtpUsecase(repository: ref.read(authRecoveryRepositoryProvider));
});

class VerifyOtpUsecase
    implements UsecaseWithParams<ResetTokenEntity, VerifyOtpParams> {
  final AuthRecoveryRepository _repository;

  VerifyOtpUsecase({required AuthRecoveryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ResetTokenEntity>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(email: params.email, otp: params.otp);
  }
}
