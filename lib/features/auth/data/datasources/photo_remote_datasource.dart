// lib/features/auth/data/datasources/photo_remote_datasource.dart
import 'dart:io';

import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/api_service.dart';
import 'package:dio/dio.dart';

class PhotoRemoteDatasource {
  final ApiService apiService;

  PhotoRemoteDatasource({required this.apiService});

  String _toAbsoluteUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${ApiEndpoints.baseUrl}$v';
    return '${ApiEndpoints.baseUrl}/$v';
  }

  Future<List<String>> uploadPhoto(File file) async {
    final formData = FormData.fromMap({
      "photo": await MultipartFile.fromFile(file.path),
    });

    final res = await apiService.dio.post(
      ApiEndpoints.uploadPhoto,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );

    final data = Map<String, dynamic>.from(res.data);
    return (data["photos"] as List)
        .map((e) => _toAbsoluteUrl(e.toString()))
        .toList();
  }

  Future<List<String>> deletePhotoByIndex(int index) async {
    final res = await apiService.dio.delete(
      "${ApiEndpoints.deletePhoto}/$index",
    );
    final data = Map<String, dynamic>.from(res.data);
    return (data["photos"] as List)
        .map((e) => _toAbsoluteUrl(e.toString()))
        .toList();
  }
}
