import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  /// Register a new user
  Future<Either<Failure, void>> registerUser(AuthEntity user);

  /// Login user and return token
  Future<Either<Failure, String>> loginUser(String email, String password);
}
