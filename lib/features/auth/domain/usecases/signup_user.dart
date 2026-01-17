import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

class SignupParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const SignupParams({
    required this.username,
    required this.email,
    required this.password,
  });

  const SignupParams.initial() : username = '', email = '', password = '';

  @override
  List<Object> get props => [username, email, password];
}

class SignupUser implements UsecaseWithParams<void, SignupParams> {
  final IAuthRepository repository;

  SignupUser(this.repository);

  @override
  Future<Either<Failure, void>> call(SignupParams params) async {
    final user = AuthEntity(
      username: params.username,
      email: params.email,
      password: params.password,
    );

    return repository.registerUser(user);
  }
}
