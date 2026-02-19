import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class ProfileRemoteDatasource {
  final ApiService apiService;
  ProfileRemoteDatasource({required this.apiService});

  Future<Map<String, dynamic>> getMe() async {
    final res = await apiService.dio.get(ApiEndpoints.getMe);
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async {
    final res = await apiService.dio.put(ApiEndpoints.updateMe, data: body);
    return Map<String, dynamic>.from(res.data);
  }
}
