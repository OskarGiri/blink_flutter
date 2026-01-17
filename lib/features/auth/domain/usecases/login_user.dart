// import 'package:blink_flutter/features/auth/data/models/user_model.dart';

// import '../repositories/auth_repository.dart';

// class LoginUser {
//   final AuthRepository repository;

//   LoginUser(this.repository);

//   Future<UserModel?> call(String email, String password) async {
//     return repository.login(email, password);
//   }
// }

import 'package:blink_flutter/core/usecase/usecase_with_params.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  const LoginParams.initial() : email = '', password = '';

  @override
  List<Object> get props => [email, password];
}

class LoginUseCase implements UsecaseWithParams<String, LoginParams> {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(LoginParams params) async {
    return repository.loginUser(params.email, params.password);
  }
}
