// lib/core/services/hive/hive_service.dart
import 'dart:convert';

import 'package:blink_flutter/core/constants/hive_table_constant.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // ========================= Init =========================
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";

    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.usersTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)) {
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.usersTable);
    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileTable);

    // ✅ discovery cache (String box)
    await Hive.openBox<String>(HiveTableConstant.discoveryCacheBox);

    // ✅ pending swipes queue (String box)
    await Hive.openBox<String>(HiveTableConstant.pendingSwipesBox);

    // ✅ matches cache (String box)
    await Hive.openBox<String>(HiveTableConstant.matchesCacheBox);
  }

  Future<void> closeBoxes() async {
    await Hive.close();
  }

  Future<void> deleteEntireBox() async {
    var box = await Hive.openBox('myBox');
    await box.deleteFromDisk();
  }

  Future<void> deleteAllDatabases() async {
    await Hive.deleteFromDisk();
  }

  // ========================= Users CRUD =========================
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

  // ========================= Profile CRUD =========================
  Box<ProfileHiveModel> get _profileBox =>
      Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable);

  /// ✅ REAL-TIME: use this in UI via ValueListenableBuilder
  ValueListenable<Box<ProfileHiveModel>> profileListenable() {
    return _profileBox.listenable();
  }

  /// ✅ REAL-TIME: sync read (no FutureBuilder)
  ProfileHiveModel? getProfileByUserIdSync(String userId) {
    return _profileBox.get(userId);
  }

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

  // ========================= Discovery Cache (OFFLINE) =========================
  Box<String> get _discoveryBox =>
      Hive.box<String>(HiveTableConstant.discoveryCacheBox);

  Future<void> saveDiscoveryCache(String userId, List<dynamic> jsonList) async {
    await _discoveryBox.put("discovery_$userId", jsonEncode(jsonList));
  }

  Future<List<dynamic>> getDiscoveryCache(String userId) async {
    final raw = _discoveryBox.get("discovery_$userId");
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    return decoded is List ? decoded : [];
  }

  Future<void> clearDiscoveryCache(String userId) async {
    await _discoveryBox.delete("discovery_$userId");
  }

  // ========================= Pending Swipes Queue (OFFLINE) =========================
  Box<String> get _pendingSwipesBox =>
      Hive.box<String>(HiveTableConstant.pendingSwipesBox);

  Future<List<Map<String, dynamic>>> getPendingSwipes(String userId) async {
    final raw = _pendingSwipesBox.get("pending_swipes_$userId");
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> savePendingSwipes(
    String userId,
    List<Map<String, dynamic>> swipes,
  ) async {
    await _pendingSwipesBox.put("pending_swipes_$userId", jsonEncode(swipes));
  }

  Future<void> enqueueSwipe({
    required String userId,
    required String targetUserId,
    required String action, // "like" | "pass"
  }) async {
    final list = await getPendingSwipes(userId);
    list.add({
      "id": "${DateTime.now().millisecondsSinceEpoch}_${targetUserId}_$action",
      "targetUserId": targetUserId,
      "action": action,
      "createdAt": DateTime.now().toIso8601String(),
    });
    await savePendingSwipes(userId, list);
  }

  Future<void> removePendingSwipeById(String userId, String id) async {
    final list = await getPendingSwipes(userId);
    list.removeWhere((e) => (e["id"] ?? "").toString() == id);
    await savePendingSwipes(userId, list);
  }

  Future<void> clearPendingSwipes(String userId) async {
    await _pendingSwipesBox.delete("pending_swipes_$userId");
  }

  // ========================= Matches Cache (OFFLINE) =========================
  Box<String> get _matchesBox =>
      Hive.box<String>(HiveTableConstant.matchesCacheBox);

  Future<void> saveMatchesCache(String userId, List<dynamic> jsonList) async {
    await _matchesBox.put("matches_$userId", jsonEncode(jsonList));
  }

  Future<List<dynamic>> getMatchesCache(String userId) async {
    final raw = _matchesBox.get("matches_$userId");
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    return decoded is List ? decoded : [];
  }

  Future<void> clearMatchesCache(String userId) async {
    await _matchesBox.delete("matches_$userId");
  }
}
