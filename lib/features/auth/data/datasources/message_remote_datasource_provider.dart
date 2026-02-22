import 'package:blink_flutter/core/network/api_providers.dart';
import 'package:blink_flutter/features/auth/data/datasources/messages_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagesRemoteDatasourceProvider = Provider<MessagesRemoteDatasource>((
  ref,
) {
  return MessagesRemoteDatasource(apiService: ref.read(apiServiceProvider));
});
