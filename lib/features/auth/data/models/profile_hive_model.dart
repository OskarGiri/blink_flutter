import 'package:hive/hive.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 10)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String? gender;

  @HiveField(3)
  final String? dob; // yyyy-mm-dd

  // ✅ NEW
  @HiveField(4)
  final String? lookingFor;

  @HiveField(5)
  final bool pendingSync;

  ProfileHiveModel({
    required this.userId,
    required this.fullName,
    this.gender,
    this.dob,
    this.lookingFor,
    this.pendingSync = true,
  });

  ProfileHiveModel copyWith({
    String? userId,
    String? fullName,
    String? gender,
    String? dob,
    String? lookingFor,
    bool? pendingSync,
  }) {
    return ProfileHiveModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      lookingFor: lookingFor ?? this.lookingFor,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
