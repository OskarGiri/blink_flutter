import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel extends Equatable {
  @JsonKey(name: 'id')
  final String? userId;

  @JsonKey(name: 'username')
  final String username;

  final String email;

  @JsonKey(includeIfNull: false) // ✅ FIX: Optional password
  final String? password; // ✅ FIX: Make nullable

  const AuthApiModel({
    this.userId,
    required this.username,
    required this.email,
    this.password, // ✅ Optional
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId ?? '',
      username: username,
      email: email,
      password: password ?? '', // ✅ Safe default
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      password: entity.password,
    );
  }

  @override
  List<Object?> get props => [userId, username, email, password];
}
