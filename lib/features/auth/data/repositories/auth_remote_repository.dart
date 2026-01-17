import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class AuthRemoteRepository implements IAuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthRemoteRepository(this._authRemoteDataSource);

  @override
  Future<Either<Failure, String>> loginUser(
    String email,
    String password,
  ) async {
    try {
      debugPrint("Calling login API: email=$email, password=$password");
      final token = await _authRemoteDataSource.loginUser(email, password);
      return Right(token);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(AuthEntity user) async {
    try {
      debugPrint("Calling register API");
      await _authRemoteDataSource.registerUser(user);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
