// lib/features/discovery/data/swipe_remote_datasource_provider.dart
import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_remote_datasource.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final swipeRemoteDatasourceProvider = Provider<SwipeRemoteDatasource>((ref) {
  return SwipeRemoteDatasource(apiService: ref.read(apiServiceProvider));
});