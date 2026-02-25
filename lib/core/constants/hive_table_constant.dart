// lib/core/constants/hive_table_constant.dart
class HiveTableConstant {
  HiveTableConstant._();

  static const String dbName = "blink_db";

  static const int usersTypeId = 0;
  static const String usersTable = "usersTable";

  static const int profileTypeId = 10;
  static const String profileTable = "profileTable";

  static const String pendingSwipesBox = "pendingSwipesBox";
  static const String matchesCacheBox = "matchesCacheBox";

  // ✅ NEW: discovery cache box (no adapter needed)
  static const String discoveryCacheBox = "discoveryCacheBox";
}
