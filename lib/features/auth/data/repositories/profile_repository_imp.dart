import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:blink_flutter/features/auth/data/mappers/profile_mapper.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';

class ProfileRepositoryImpl {
  final NetworkInfo networkInfo;
  final HiveService hiveService;
  final UserSessionService session;
  final ProfileRemoteDatasource remote;

  ProfileRepositoryImpl({
    required this.networkInfo,
    required this.hiveService,
    required this.session,
    required this.remote,
  });

  String get _userId => session.getCurrentUserId() ?? "guest";

  Future<ProfileHiveModel?> getProfile() async {
    final isOnline = await networkInfo.isConnected;

    // Offline → Hive only
    if (!isOnline) {
      return hiveService.getProfileByUserId(_userId);
    }

    // Online → API first, cache in Hive
    final json = await remote.getMe();
    final model = ProfileMapper.fromApi(userId: _userId, json: json);
    await hiveService.saveProfile(model);
    return model;
  }

  Future<ProfileHiveModel?> updateProfile(ProfileHiveModel model) async {
    final isOnline = await networkInfo.isConnected;

    // Offline → save local + pendingSync
    if (!isOnline) {
      final offlineModel = ProfileHiveModel(
        userId: model.userId,
        fullName: model.fullName,
        dob: model.dob,
        gender: model.gender,
        lookingFor: model.lookingFor,
        pendingSync: true,
      );
      return hiveService.saveProfile(offlineModel);
    }

    // Online → PUT API + cache result
    await remote.updateMe(ProfileMapper.toApi(model));
    final refreshed = await remote.getMe();
    final newModel = ProfileMapper.fromApi(userId: _userId, json: refreshed);
    await hiveService.saveProfile(newModel);
    return newModel;
  }
}
