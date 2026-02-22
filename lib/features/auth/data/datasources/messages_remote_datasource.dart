import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class MessagesRemoteDatasource {
  final ApiService apiService;
  MessagesRemoteDatasource({required this.apiService});

  Future<List<Map<String, dynamic>>> getMessages({
    required String matchId,
    int limit = 50,
  }) async {
    final res = await apiService.dio.get(
      ApiEndpoints.matchMessages(matchId),
      queryParameters: {'limit': limit},
    );

    if (res.data is! List) return [];
    return List<dynamic>.from(
      res.data,
    ).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> sendMessage({
    required String matchId,
    required String text,
  }) async {
    final res = await apiService.dio.post(
      ApiEndpoints.matchMessages(matchId),
      data: {'text': text},
    );
    if (res.data is Map) return Map<String, dynamic>.from(res.data);
    return {};
  }
}
