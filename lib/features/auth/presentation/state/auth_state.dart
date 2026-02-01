import 'package:blink_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  created,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final List<UserEntity> users;
  final String? message;

  const AuthState({this.status = AuthStatus.initial, this.users = const [], this.message});

  AuthState copyWith({
    AuthStatus? status,
    List<UserEntity>? users,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      users: users ?? this.users,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, users, message];
}
