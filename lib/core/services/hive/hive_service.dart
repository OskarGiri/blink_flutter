// lib/core/services/hive/hive_service.dart
import 'package:blink_flutter/core/constants/hive_table_constant.dart';
import 'package:blink_flutter/features/auth/data/models/user_hive_model.dart';
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

  // Register All Types of adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.usersTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
  }

  // if (!Hive.isAdapterRegistered(HiveTableConstant.pendingEmailsTypeId)) {
  // Hive.registerAdapter(BuyerHiveModelAdapter());
  // }

  // Open all boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.usersTable);
    // await Hive.openBox<UserHiveModel>(HiveTableConstant.pendingEmailsTable);
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
  // Get users box
  Box<UserHiveModel> get _usersBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.usersTable);

  // Create a new user
  Future<UserHiveModel?> createUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  // Create a existing user
  Future<UserHiveModel?> updateUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  // Get a existing user by ID
  Future<UserHiveModel?> getUserById(String userId) async {
    return _usersBox.get(userId);
  }

  // Get a existing user by email
  Future<UserHiveModel?> getUserByEmail(String email) async {
    final users = _usersBox.values.where((user) => user.email == email);
    return users.firstOrNull;
  }

  // Get all users
  Future<List<UserHiveModel>> getAllUsers() async {
    return _usersBox.values.toList();
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await _usersBox.delete(userId);
  }

  // Delete all users
  Future<void> deleteAllUsers() async {
    await _usersBox.clear();
  }

  // // ---------------------------- Buyers ------------------------------
  // // Get buyers box
  // Box<BuyerHiveModel> get _buyersBox =>
  //     Hive.box<BuyerHiveModel>(HiveTableConstant.buyersTable);

  // Future<BuyerHiveModel?> createBuyer(BuyerHiveModel buyerModel) async {
  //   await _buyersBox.put(buyerModel.buyerId, buyerModel);
  //   return buyerModel;
  // }

  // // Create a existing buyer
  // Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerModel) async {
  //   await _buyersBox.put(buyerModel.buyerId, buyerModel);
  //   return buyerModel;
  // }

  // // Get a existing buyer by ID
  // Future<BuyerHiveModel?> getBuyerById(String buyerId) async {
  //   return _buyersBox.get(buyerId);
  // }

  // // Get a existing buyer by Base User ID
  // Future<BuyerHiveModel?> getBuyerByBaseUserId(String userId) async {
  //   return _buyersBox.get(userId);
  // }

  // // Get a existing buyer by username
  // Future<BuyerHiveModel?> getBuyerByUsername(String username) async {
  //   final buyers = _buyersBox.values.where((buyer) => buyer.username == username);
  //   return buyers.first;
  // }

  // // Get a existing buyer by phoneNumber
  // Future<BuyerHiveModel?> getBuyerByPhoneNumber(String phoneNumber) async {
  //   final buyers = _buyersBox.values.where(
  //     (buyer) => buyer.phoneNumber == phoneNumber,
  //   );
  //   return buyers.first;
  // }

  // // Get all buyers
  // Future<List<BuyerHiveModel>> getAllBuyers() async {
  //   return _buyersBox.values.toList();
  // }

  // // Delete a buyer
  // Future<void> deleteBuyer(String buyerId) async {
  //   await _buyersBox.delete(buyerId);
  // }

  // // Delete all buyers
  // Future<void> deleteAllBuyers() async {
  //   await _buyersBox.clear();
  // }

  // // ---------------------------- Pending Emails Queue ------------------------------
  // // Get pending emails box
  // Box<Map<String, dynamic>> get _pendingEmailsBox =>
  //     Hive.box<Map<String, dynamic>>(HiveTableConstant.pendingEmailsTable);

  // // Queue OTP email
  // Future<String> queueOtpEmail({
  //   required String toEmail,
  //   required String fullName,
  //   required String otp,
  //   DateTime? expiryDate,
  // }) async {
  //   final key = DateTime.now().millisecondsSinceEpoch.toString();
  //   final data = {
  //     'toEmail': toEmail,
  //     'fullName': fullName,
  //     'otp': otp,
  //     'expiryDate': expiryDate,
  //     'createdAt': DateTime.now().toIso8601String(),
  //     'attempts': 0,
  //   };
  //   await _pendingEmailsBox.put(key, data);
  //   return key;
  // }

  // // Returns a list of pending email entries. Each entry ALWAYS includes 'key' for deletion.
  // Future<List<Map<String, dynamic>>> getPendingEmails() async {
  //   final List<Map<String, dynamic>> out = [];
  //   for (final key in _pendingEmailsBox.keys) {
  //     final value = _pendingEmailsBox.get(key);
  //     if (value is Map) {
  //       final map = Map<String, dynamic>.from(value as Map);
  //       map['key'] = key.toString();
  //       out.add(map);
  //     }
  //   }
  //   return out;
  // }

  // // Delete from queue
  // Future<void> deleteFromQueue(String key) async {
  //   await _pendingEmailsBox.delete(key);
  // }

  // // Increment attempts counter for a queue item
  // Future<void> incrementQueueAttempts(String key) async {
  //   final value = _pendingEmailsBox.get(key);
  //   if (value is Map) {
  //     final m = Map<String, dynamic>.from(value as Map);
  //     final attempts = (m['attempts'] as int?) ?? 0;
  //     m['attempts'] = attempts + 1;
  //     await _pendingEmailsBox.put(key, m);
  //   }
}
