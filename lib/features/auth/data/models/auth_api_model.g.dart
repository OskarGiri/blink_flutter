// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
      userId: json['id'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) {
  final val = <String, dynamic>{
    'id': instance.userId,
    'username': instance.username,
    'email': instance.email,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('password', instance.password);
  return val;
}
