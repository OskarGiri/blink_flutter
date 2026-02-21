// lib/features/discovery/data/discovery_remote_datasource_provider.dart
import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/discovery_remote_datasource.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final discoveryRemoteDatasourceProvider = Provider<DiscoveryRemoteDatasource>((
  ref,
) {
  return DiscoveryRemoteDatasource(apiService: ref.read(apiServiceProvider));
});
