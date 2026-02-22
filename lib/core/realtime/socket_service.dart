import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  final _matchNew = StreamController<Map<String, dynamic>>.broadcast();
  final _messageNew = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get matchNewStream => _matchNew.stream;
  Stream<Map<String, dynamic>> get messageNewStream => _messageNew.stream;

  bool get isConnected => _socket?.connected == true;

  void connect({required String baseUrl, required String token}) {
    disconnect();

    _socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 999,
      'reconnectionDelay': 500,
      'auth': {'token': token},
    });

    _socket!.onConnect((_) {
      debugPrint("✅ SOCKET_CONNECTED");
    });

    _socket!.onDisconnect((_) {
      debugPrint("⚠️ SOCKET_DISCONNECTED");
    });

    _socket!.onConnectError((e) {
      debugPrint("❌ SOCKET_CONNECT_ERROR=$e");
    });

    _socket!.onError((e) {
      debugPrint("❌ SOCKET_ERROR=$e");
    });

    _socket!.on('match:new', (data) {
      if (data is Map) {
        _matchNew.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('message:new', (data) {
      if (data is Map) {
        _messageNew.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    final s = _socket;
    if (s == null) return;

    s.off('match:new');
    s.off('message:new');
    s.disconnect();
    s.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _matchNew.close();
    _messageNew.close();
  }
}
