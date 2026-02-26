import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';

class ProfileMapper {
  static ProfileHiveModel fromApi({
    required String userId,
    required Map<String, dynamic> json,
  }) {
    return ProfileHiveModel(
      userId: userId,
      fullName: (json['fullName'] ?? json['username'] ?? '').toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      lookingFor: json['lookingFor']?.toString(),
      pendingSync: false,
    );
  }

  static Map<String, dynamic> toApi(ProfileHiveModel model) {
    return {
      "fullName": model.fullName,
      "dob": model.dob,
      "gender": model.gender,
      "lookingFor": model.lookingFor,
    };
  }
}
