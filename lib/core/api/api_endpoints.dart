class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Base URL (Android Emulator)
  static const String baseUrl = "http://10.0.2.2:3000";

  // ====================== Auth Routes ======================
  static const String login = "$baseUrl/users/login";
  static const String register = "$baseUrl/users/signup";
}
