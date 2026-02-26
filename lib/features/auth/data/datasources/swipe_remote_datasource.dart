// lib/features/discovery/data/swipe_remote_datasource.dart
import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class SwipeRemoteDatasource {
  final ApiService apiService;
  SwipeRemoteDatasource({required this.apiService});

  Future<Map<String, dynamic>> swipe({
    required String targetUserId,
    required String action, // "like" | "pass"
  }) async {
    final res = await apiService.dio.post(
      ApiEndpoints.swipes,
      data: {"targetUserId": targetUserId, "action": action},
    );

    return Map<String, dynamic>.from(res.data);
  }
}
