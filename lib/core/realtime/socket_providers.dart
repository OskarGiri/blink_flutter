import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final s = SocketService();
  ref.onDispose(s.dispose);
  return s;
});

// Function to initialize socket connection with token
final initializeSocketProvider = FutureProvider<void>((ref) async {
  final socketService = ref.watch(socketServiceProvider);

  // Only connect if not already connected
  if (!socketService.isConnected) {
    // Use 10.0.2.2 for Android emulator, localhost for web/other
    const baseUrl = 'http://10.0.2.2:3000';

    // Get token from wherever it's stored (will be injected by caller)
    // This provider handles the connection initialization
    socketService.connect(baseUrl: baseUrl, token: 'bearer_token_placeholder');
  }
});

final matchNewStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).matchNewStream;
});

final messageNewStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(socketServiceProvider).messageNewStream;
});
