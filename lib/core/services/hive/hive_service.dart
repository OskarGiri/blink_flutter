// lib/core/services/hive/hive_service.dart
import 'package:blink_flutter/core/constants/hive_table_constant.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';// ✅ NEW
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";

    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  // Register all adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.usersTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }

    // ✅ NEW Profile Adapter
    if (!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)) {
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
  }

  // Open all boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.usersTable);

    // ✅ NEW Profile Box
    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileTable);
  }

  // Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }

  // The box file is deleted. Need to open the box again to use it.
  Future<void> deleteEntireBox() async {
    var box = await Hive.openBox('myBox');
    await box.deleteFromDisk();
  }

  // All Hive data associated with the application is removed.
  Future<void> deleteAllDatabases() async {
    await Hive.deleteFromDisk();
  }

  // ========================= CRUD Operations ========================
  // ---------------------------- Users ------------------------------
  Box<UserHiveModel> get _usersBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.usersTable);

  Future<UserHiveModel?> createUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  Future<UserHiveModel?> updateUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  Future<UserHiveModel?> getUserById(String userId) async {
    return _usersBox.get(userId);
  }

  Future<UserHiveModel?> getUserByEmail(String email) async {
    final users = _usersBox.values.where((user) => user.email == email);
    return users.firstOrNull;
  }

  Future<List<UserHiveModel>> getAllUsers() async {
    return _usersBox.values.toList();
  }

  Future<void> deleteUser(String userId) async {
    await _usersBox.delete(userId);
  }

  Future<void> deleteAllUsers() async {
    await _usersBox.clear();
  }

  // ---------------------------- Profile ------------------------------
  // ✅ NEW Profile CRUD (minimal for Step 2.1)
  Box<ProfileHiveModel> get _profileBox =>
      Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable);

  Future<ProfileHiveModel?> saveProfile(ProfileHiveModel profile) async {
    await _profileBox.put(profile.userId, profile);
    return profile;
  }

  Future<ProfileHiveModel?> getProfileByUserId(String userId) async {
    return _profileBox.get(userId);
  }

  Future<void> clearProfileBox() async {
    await _profileBox.clear();
  }
}
