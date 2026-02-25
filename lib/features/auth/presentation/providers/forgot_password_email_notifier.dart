import 'package:blink_flutter/features/auth/domain/usecases/send_forgot_password_otp_usecase.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_recovery_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordEmailNotifierProvider =
    NotifierProvider<ForgotPasswordEmailNotifier, AuthRecoveryState>(
      ForgotPasswordEmailNotifier.new,
    );

class ForgotPasswordEmailNotifier extends Notifier<AuthRecoveryState> {
  late final SendForgotPasswordOtpUsecase _sendForgotPasswordOtpUsecase;

  @override
  AuthRecoveryState build() {
    _sendForgotPasswordOtpUsecase = ref.read(
      sendForgotPasswordOtpUsecaseProvider,
    );
    return const AuthRecoveryState();
  }

  Future<void> sendOtp(String email) async {
    state = const AuthRecoveryState(status: AuthRecoveryStatus.loading);

    final result = await _sendForgotPasswordOtpUsecase(
      SendForgotPasswordOtpParams(email: email),
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
