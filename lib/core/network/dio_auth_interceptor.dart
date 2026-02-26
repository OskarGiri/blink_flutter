import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:dio/dio.dart';

class DioAuthInterceptor extends Interceptor {
  final TokenService tokenService;

  DioAuthInterceptor({required this.tokenService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await tokenService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // ignore token errors
    }
    handler.next(options);
  }
}
