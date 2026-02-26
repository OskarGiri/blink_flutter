import 'package:blink_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? password;

  @HiveField(3)
  final String username;

  UserHiveModel({
    String? userId,
    required this.email,
    this.password,
    required this.username,
  }) : userId = userId ?? Uuid().v4();

  UserEntity toEntity() =>
      UserEntity(email: email, password: password, username: username);

  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      userId: entity.userId,
      email: entity.email,
      password: entity.password,
      username: entity.username,
    );
  }

  static List<UserEntity> toEntityList(List<UserHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  UserHiveModel copyWith({
    String? userId,
    String? email,
    String? password,
    String? username,
  }) {
    return UserHiveModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
    );
  }
}
