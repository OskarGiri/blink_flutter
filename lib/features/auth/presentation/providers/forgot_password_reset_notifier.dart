import 'package:blink_flutter/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_recovery_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordResetNotifierProvider =
    NotifierProvider<ForgotPasswordResetNotifier, AuthRecoveryState>(
      ForgotPasswordResetNotifier.new,
    );

class ForgotPasswordResetNotifier extends Notifier<AuthRecoveryState> {
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthRecoveryState build() {
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthRecoveryState();
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    state = const AuthRecoveryState(status: AuthRecoveryStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) => state = AuthRecoveryState(
        status: AuthRecoveryStatus.error,
        message: failure.message,
      ),
      (message) => state = AuthRecoveryState(
        status: AuthRecoveryStatus.success,
        message: message,
      ),
    );
  }

  void resetState() {
    state = const AuthRecoveryState();
  }
}
