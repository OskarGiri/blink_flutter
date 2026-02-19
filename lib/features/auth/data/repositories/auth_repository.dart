import 'package:bcrypt/bcrypt.dart';
import 'package:blink_flutter/core/error/failure.dart';
import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_data_source.dart';
import 'package:blink_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:blink_flutter/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:blink_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDataSource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authLocalDataSource: authLocalDataSource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authLocalDataSource,
    required IAuthDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authLocalDataSource = authLocalDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.loginUser(email, password);

        if (apiModel == null) {
          return const Left(ApiFailure(message: "Invalid credentials"));
        }

        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    // Offline (Hive)
    try {
      final existingUser = await _authLocalDataSource.getUserByEmail(email);

      if (existingUser == null) {
        return Left(LocalDatabaseFailure(message: 'User not found'));
      }

      final isMatched = BCrypt.checkpw(password, existingUser.password ?? '');

      if (!isMatched) {
        return Left(LocalDatabaseFailure(message: 'Incorrect password'));
      }

      return Right(
        AuthEntity(
          userId: existingUser.userId,
          username: existingUser.username,
          email: existingUser.email,
          password: existingUser.password ?? '',
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

 @override
Future<Either<Failure, UserEntity>> signUp(UserEntity userEntity) async {
  debugPrint("🔥 === SIGNUP STARTED ===");
  final isOnline = await _networkInfo.isConnected;
  debugPrint("🌐 Network: ${isOnline ? 'ONLINE' : 'OFFLINE'}");
  
  if (isOnline) {
    debugPrint("🚀 CALLING API registerUser...");
    try {
      final apiModel = await _authRemoteDataSource.registerUser(

          username: userEntity.username ?? '',
          email: userEntity.email,
          password: userEntity.password ?? '',
        );

        if (apiModel == null) {
          return const Left(ApiFailure(message: "Sign up failed"));
        }

        // Cache the user locally after successful API signup
        final authEntity = apiModel.toEntity();
        final cachedUserEntity = UserEntity(
          userId: authEntity.userId,
          username: authEntity.username,
          email: authEntity.email,
          password: authEntity.password,
        );
        final userModel = UserHiveModel.fromEntity(cachedUserEntity);
        await _authLocalDataSource.createUser(userModel);

        return Right(cachedUserEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Sign up failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    // Offline - Use Hive only
    try {
      final userModel = UserHiveModel.fromEntity(userEntity);

      // Check existing user
      final existingUserByEmail = await _authLocalDataSource.getUserByEmail(
        userEntity.email,
      );
      if (existingUserByEmail != null) {
        return Left(LocalDatabaseFailure(message: 'Email already exists'));
      }

      final hashedPassword = BCrypt.hashpw(
        userModel.password ?? "",
        BCrypt.gensalt(),
      );

      final createdUserModel = await _authLocalDataSource.createUser(
        userModel.copyWith(password: hashedPassword),
      );

      if (createdUserModel == null) {
        return Left(LocalDatabaseFailure(message: 'Failed to create user'));
      }

      return Right(createdUserModel.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
