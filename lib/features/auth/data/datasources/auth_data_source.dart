import 'package:blink_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';
import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthLocalDataSource {
  Future<UserHiveModel?> createUser(UserHiveModel userModel);
  Future<UserHiveModel?> updateUser(UserHiveModel userModel);
  Future<UserHiveModel?> getUserById(String userId);
  Future<UserHiveModel?> getUserByEmail(String email);
}

abstract class IAuthDataSource {
  Future<AuthApiModel?> loginUser(String email, String password);
  
  // ✅ UPDATED: Returns AuthApiModel instead of void
  Future<AuthApiModel?> registerUser({
    required String username,
    required String email,
    required String password,
  });
}
