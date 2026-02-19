import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>((ref) {
  return ProfileLocalDatasource();
});

class ProfileLocalDatasource {
  static const String _boxName = "profileBox";

  Future<Box<ProfileHiveModel>> _openBox() async {
    return Hive.openBox<ProfileHiveModel>(_boxName);
  }

  Future<void> saveProfile(ProfileHiveModel profile) async {
    final box = await _openBox();
    await box.put(profile.userId, profile);
  }

  Future<ProfileHiveModel?> getProfile(String userId) async {
    final box = await _openBox();
    return box.get(userId);
  }

  Future<void> clearProfile() async {
    final box = await _openBox();
    await box.clear();
  }
}
