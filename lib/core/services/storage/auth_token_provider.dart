import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user-session_service.dart';

final authTokenProvider = Provider<String>((ref) {
  return ref.read(userSessionServiceProvider).getToken() ?? '';
});
