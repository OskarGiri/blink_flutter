import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final s = SocketService();
  ref.onDispose(s.dispose);
  return s;
});

final matchNewStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).matchNewStream;
});

final messageNewStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).messageNewStream;
});
