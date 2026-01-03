import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox');

  Future<void> signup(String email, String password) async {
    await _box.put(email, password);
  }

  Future<bool> login(String email, String password) async {
    final storedPassword = _box.get(email);
    return storedPassword != null && storedPassword == password;
  }

  Future<bool> isLoggedIn() async {
    return _box.isNotEmpty;
  }
}
