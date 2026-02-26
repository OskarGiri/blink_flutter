import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_recovery_repository_impl.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_recovery_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  final String resetToken;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, resetToken, newPassword];
}

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(
    repository: ref.read(authRecoveryRepositoryProvider),
  );
});

class ResetPasswordUsecase
    implements UsecaseWithParams<String, ResetPasswordParams> {
  final AuthRecoveryRepository _repository;

  ResetPasswordUsecase({required AuthRecoveryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      resetToken: params.resetToken,
      newPassword: params.newPassword,
    );
  }
}
