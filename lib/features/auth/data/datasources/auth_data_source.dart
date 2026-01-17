import 'dart:io';

import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthDataSource {
  Future<String> loginUser(String email, String password);

  Future<void> registerUser(AuthEntity user);
}
