import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';


part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final String username;

  UserModel({
    required this.email,
    required this.password,
    required this.username,
  });

  AuthEntity toEntity() => AuthEntity(email: email, password: password, username: username);
}
