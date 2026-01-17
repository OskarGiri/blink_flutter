import 'package:blink_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? userId;
  final String username;
  final String email;
  final String password;

  const AuthApiModel({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
  });

  /// FROM JSON (API → Model)
  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  /// TO JSON (Model → API)
  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  /// MODEL → DOMAIN ENTITY
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      username: username,
      email: email,
      password: password,
    );
  }

  /// DOMAIN ENTITY → MODEL
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
