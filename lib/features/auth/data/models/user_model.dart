import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  UserModel({
    required this.email,
    required this.password,
  });

  User toEntity() => User(email: email, password: password);
}
