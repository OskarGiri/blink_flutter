import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/photo_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoRemoteDatasourceProvider = Provider<PhotoRemoteDatasource>((ref) {
  final api = ref.read(apiServiceProvider);
  return PhotoRemoteDatasource(apiService: api);
});
