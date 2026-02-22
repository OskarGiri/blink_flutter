import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Set to your PC LAN IP when running on real phones.
  /// Example: flutter run --dart-define=LAN_HOST=192.168.1.10
  static const String lanHost = String.fromEnvironment(
    'LAN_HOST',
    defaultValue: '192.168.1.10',
  );

  static String get host {
    if (kIsWeb) return 'localhost';

    if (Platform.isAndroid) {
      // Emulator uses 10.0.2.2; real phone uses LAN_HOST.
      // If you haven't overridden LAN_HOST, defaultValue is used -> treat as emulator.
      final usingDefault = lanHost == '192.168.1.10';
      return usingDefault ? '10.0.2.2' : lanHost;
    }

    // iOS simulator + real device: use LAN_HOST
    return lanHost;
  }

  static String get httpBaseUrl => 'http://$host:3000';
  static String get socketBaseUrl => httpBaseUrl; // Socket.IO uses same origin
}
