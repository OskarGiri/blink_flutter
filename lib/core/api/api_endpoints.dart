// lib/core/api/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "http://10.0.2.2:3000";

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
}
