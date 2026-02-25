import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_recovery_repository_impl.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_recovery_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendForgotPasswordOtpParams extends Equatable {
  final String email;

  const SendForgotPasswordOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final sendForgotPasswordOtpUsecaseProvider =
    Provider<SendForgotPasswordOtpUsecase>((ref) {
      return SendForgotPasswordOtpUsecase(
        repository: ref.read(authRecoveryRepositoryProvider),
      );
    });

class SendForgotPasswordOtpUsecase
    implements UsecaseWithParams<String, SendForgotPasswordOtpParams> {
  final AuthRecoveryRepository _repository;

  SendForgotPasswordOtpUsecase({required AuthRecoveryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, String>> call(SendForgotPasswordOtpParams params) {
    return _repository.sendForgotPasswordOtp(params.email);
  }
}
