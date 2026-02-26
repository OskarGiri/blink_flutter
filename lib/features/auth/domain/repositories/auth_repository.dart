import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:blink_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, UserEntity>> signUp(UserEntity userEntity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  // Future<Either<Failure, bool>> logout();
}
