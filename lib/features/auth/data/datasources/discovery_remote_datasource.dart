// lib/features/auth/data/datasources/discovery_remote_datasource.dart
import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class DiscoveryRemoteDatasource {
  final ApiService apiService;
  DiscoveryRemoteDatasource({required this.apiService});

  String _toAbsoluteUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${ApiEndpoints.baseUrl}$v';
    return '${ApiEndpoints.baseUrl}/$v';
  }

  List<dynamic> _normalizeList(List<dynamic> list) {
    return list.map((e) {
      if (e is! Map) return e;
      final map = Map<String, dynamic>.from(e as Map);

      final photos = map['photos'];
      if (photos is List) {
        map['photos'] = photos
            .map((p) => _toAbsoluteUrl(p.toString()))
            .toList();
      }
      return map;
    }).toList();
  }

  Future<List<dynamic>> getDiscovery() async {
    final res = await apiService.dio.get(ApiEndpoints.discovery);
    if (res.data is List) {
      return _normalizeList(List<dynamic>.from(res.data));
    }
    return [];
  }
}
