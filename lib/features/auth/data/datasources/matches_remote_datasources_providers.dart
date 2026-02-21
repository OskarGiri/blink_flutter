// lib/features/matches/data/matches_remote_datasource_provider.dart
import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/matches_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchesRemoteDatasourceProvider = Provider<MatchesRemoteDatasource>((
  ref,
) {
  return MatchesRemoteDatasource(apiService: ref.read(apiServiceProvider));
});
