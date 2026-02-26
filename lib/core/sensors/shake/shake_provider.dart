import 'package:blink_flutter/core/navigation/navigation_events.dart';
import 'package:blink_flutter/core/sensors/shake/shake_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shakeEventProvider = NotifierProvider<ShakeEventNotifier, int>(
  ShakeEventNotifier.new,
);

class ShakeEventNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void emit() {
    state = state + 1;
  }
}

/// Boots the global shake detector exactly once for app lifetime.
/// Returns true when active, false on unsupported platforms.
final shakeBootstrapProvider = NotifierProvider<ShakeBootstrapNotifier, bool>(
  ShakeBootstrapNotifier.new,
);

class ShakeBootstrapNotifier extends Notifier<bool> {
  ShakeDetector? _detector;

  @override
  bool build() {
    // Android-only for this feature. Web/iOS/desktop are no-op.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    _detector ??= ShakeDetector(
      onShake: () {
        ref.read(shakeEventProvider.notifier).emit();
        ref.read(navigationCommandProvider.notifier).goToMatches();
      },
    );

    try {
      _detector!.start();
    } catch (_) {
      return false;
    }

    ref.onDispose(() {
      _detector?.dispose();
      _detector = null;
    });

    return true;
  }
}
