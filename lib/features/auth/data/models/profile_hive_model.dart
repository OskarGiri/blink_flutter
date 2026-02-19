import 'package:hive/hive.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 10) // ✅ use a new unique typeId
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final bool pendingSync;

  ProfileHiveModel({
    required this.userId,
    required this.fullName,
    this.pendingSync = true,
  });

  ProfileHiveModel copyWith({
    String? userId,
    String? fullName,
    bool? pendingSync,
  }) {
    return ProfileHiveModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
