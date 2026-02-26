import 'package:blink_flutter/core/api/api_endpoints.dart';
import 'package:blink_flutter/core/network/dio_auth_interceptor.dart';
import 'package:blink_flutter/core/network/dio_error_interceptor.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio;
  final Ref _ref;

  Dio get dio => _dio;

  ApiService(this._dio, this._ref) {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..interceptors.add(DioErrorInterceptor());

    final tokenService = _ref.read(tokenServiceProvider);
    _dio.interceptors.add(DioAuthInterceptor(tokenService: tokenService));

    _dio
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      )
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
  }

  Future<Map<String, String>> _authHeaderIfNeeded(bool auth) async {
    if (!auth) return {};

    final tokenService = _ref.read(tokenServiceProvider);
    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<Response> get(
    String path, {
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    final headers = await _authHeaderIfNeeded(auth);
    return _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(String path, dynamic data, {bool auth = false}) async {
    final headers = await _authHeaderIfNeeded(auth);
    return _dio.post(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  Future<Response> put(String path, dynamic data, {bool auth = false}) async {
    final headers = await _authHeaderIfNeeded(auth);
    return _dio.put(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  Future<Response> delete(String path, {bool auth = false}) async {
    final headers = await _authHeaderIfNeeded(auth);
    return _dio.delete(path, options: Options(headers: headers));
  }
}
