// lib/features/auth/data/datasources/profile_remote_datasource.dart
import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class ProfileRemoteDatasource {
  final ApiService apiService;

  ProfileRemoteDatasource({required this.apiService});

  String _toAbsoluteUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${ApiEndpoints.baseUrl}$v';
    return '${ApiEndpoints.baseUrl}/$v';
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    final photosRaw = data["photos"];
    if (photosRaw is List) {
      data["photos"] = photosRaw
          .map((e) => _toAbsoluteUrl(e.toString()))
          .toList();
    }
    return data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await apiService.dio.get(ApiEndpoints.getMe);
    return _normalize(Map<String, dynamic>.from(res.data));
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async {
    final res = await apiService.dio.put(ApiEndpoints.updateMe, data: body);
    return _normalize(Map<String, dynamic>.from(res.data));
  }
}
