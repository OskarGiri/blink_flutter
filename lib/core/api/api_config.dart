import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Force emulator routing (Android only).
  /// Example: flutter run --dart-define=USE_EMULATOR=true
  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );

  /// Preferred way: pass backend LAN host at run time.
  /// Example: flutter run --dart-define=LAN_HOST=192.168.1.10
  static const String lanHostOverride = '192.168.1.64';

  /// Optional local default for physical-device testing.
  /// Set this to your backend machine IP if you don't want to pass --dart-define every time.
  static const String defaultLanHost = '192.168.1.64';

  /// Port of your backend
  static const int port = 3000;

  static String get host {
    if (kIsWeb) return 'localhost';

    if (Platform.isAndroid && useEmulator) {
      return '10.0.2.2';
    }

    if (lanHostOverride.isNotEmpty) {
      return lanHostOverride;
    }

    // Physical devices should hit backend machine LAN IP
    if (Platform.isAndroid || Platform.isIOS) {
      return defaultLanHost;
    }

    return 'localhost';
  }

  static String get httpBaseUrl => 'http://$host:$port';
  static String get socketBaseUrl => httpBaseUrl;

  static Future<void> ensureInitialized() async {
    // No-op now (host is explicit and deterministic).
  }
}
