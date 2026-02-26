import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/auth_data_source.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AuthLocalDataSource(hiveService: hiveService);
});

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<UserHiveModel?> createUser(UserHiveModel userModel) async {
    final result = await _hiveService.createUser(userModel);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserByEmail(String email) async {
    final result = await _hiveService.getUserByEmail(email);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserById(String userId) async {
    final result = await _hiveService.getUserById(userId);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> updateUser(UserHiveModel userModel) async {
    final result = await _hiveService.updateUser(userModel);
    return Future.value(result);
  }
}
