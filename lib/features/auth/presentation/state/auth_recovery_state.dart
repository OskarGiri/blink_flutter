import 'package:equatable/equatable.dart';

enum AuthRecoveryStatus { initial, loading, success, error }

class AuthRecoveryState extends Equatable {
  final AuthRecoveryStatus status;
  final String? message;
  final String? resetToken;

  const AuthRecoveryState({
    this.status = AuthRecoveryStatus.initial,
    this.message,
    this.resetToken,
  });

  AuthRecoveryState copyWith({
    AuthRecoveryStatus? status,
    String? message,
    String? resetToken,
  }) {
    return AuthRecoveryState(
      status: status ?? this.status,
      message: message,
      resetToken: resetToken ?? this.resetToken,
    );
  }

  @override
  List<Object?> get props => [status, message, resetToken];
}
