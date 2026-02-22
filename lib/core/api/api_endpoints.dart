// lib/core/api/api_endpoints.dart
import 'package:blink_flutter/core/api/api_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => ApiConfig.httpBaseUrl;

  // ✅ make these RELATIVE (Dio already has baseUrl)
  static const String login = "/users/login";
  static const String register = "/users/signup";

  static const String getMe = "/users/me";
  static const String updateMe = "/users/me";
  static const String uploadPhoto = "/users/me/photos";
  static const String deletePhoto = "/users/me/photos";

  // ✅ Day 2
  static const String discovery = "/discovery";
  static const String swipes = "/swipes";
  static const String matches = "/matches";
  // add inside ApiEndpoints class
  static String matchMessages(String matchId) => "/matches/$matchId/messages";
}
