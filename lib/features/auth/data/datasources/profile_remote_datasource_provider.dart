import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  final api = ref.read(apiServiceProvider);
  return ProfileRemoteDatasource(apiService: api);
});
