import 'package:blink_flutter/features/auth/domain/usecases/send_forgot_password_otp_usecase.dart';
import 'package:blink_flutter/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_recovery_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordOtpNotifierProvider =
    NotifierProvider<ForgotPasswordOtpNotifier, AuthRecoveryState>(
      ForgotPasswordOtpNotifier.new,
    );

class ForgotPasswordOtpNotifier extends Notifier<AuthRecoveryState> {
  late final VerifyOtpUsecase _verifyOtpUsecase;
  late final SendForgotPasswordOtpUsecase _sendForgotPasswordOtpUsecase;

  @override
  AuthRecoveryState build() {
    _verifyOtpUsecase = ref.read(verifyOtpUsecaseProvider);
    _sendForgotPasswordOtpUsecase = ref.read(
      sendForgotPasswordOtpUsecaseProvider,
    );
    return const AuthRecoveryState();
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    state = const AuthRecoveryState(status: AuthRecoveryStatus.loading);

    final result = await _verifyOtpUsecase(
      VerifyOtpParams(email: email, otp: otp),
    );

    result.fold(
      (failure) => state = AuthRecoveryState(
        status: AuthRecoveryStatus.error,
        message: failure.message,
      ),
      (tokenEntity) => state = AuthRecoveryState(
        status: AuthRecoveryStatus.success,
        message: 'OTP verified',
        resetToken: tokenEntity.resetToken,
      ),
    );
  }

  Future<void> resendOtp({required String email}) async {
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
