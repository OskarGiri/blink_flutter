// lib/features/auth/data/datasources/matches_remote_datasource.dart
import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';

class MatchesRemoteDatasource {
  final ApiService apiService;
  MatchesRemoteDatasource({required this.apiService});

  String _toAbsoluteUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${ApiEndpoints.baseUrl}$v';
    return '${ApiEndpoints.baseUrl}/$v';
  }

  List<dynamic> _normalizeMatches(List<dynamic> list) {
    return list.map((e) {
      if (e is! Map) return e;
      final map = Map<String, dynamic>.from(e as Map);

      final other = map['otherUser'];
      if (other is Map) {
        final otherMap = Map<String, dynamic>.from(other);

        final photos = otherMap['photos'];
        if (photos is List) {
          otherMap['photos'] = photos
              .map((p) => _toAbsoluteUrl(p.toString()))
              .toList();
        }

        map['otherUser'] = otherMap;
      }
      return map;
    }).toList();
  }

  Future<List<dynamic>> getMatches() async {
    final res = await apiService.dio.get(ApiEndpoints.matches);
    if (res.data is List) {
      return _normalizeMatches(List<dynamic>.from(res.data));
    }
    return [];
  }
}
