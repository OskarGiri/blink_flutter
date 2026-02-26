import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:blink_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpUsecaseParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const SignUpUsecaseParams({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

final signUpUsecaseProvider = Provider<SignUpUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);

  return SignUpUsecase(authRepository: authRepository);
});

class SignUpUsecase
    implements UsecaseWithParams<UserEntity, SignUpUsecaseParams> {
  final IAuthRepository _authRepository;

  SignUpUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(SignUpUsecaseParams params) async {
    UserEntity userEntity = UserEntity(
      username: params.username,
      email: params.email,
      password: params.password,
    );

    return _authRepository.signUp(userEntity);
  }
}
