import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  ShakeDetector({
    required this.onShake,
    this.threshold = 3.5,
    this.cooldown = const Duration(milliseconds: 1000),
    this.debounce = const Duration(milliseconds: 180),
  });

  final void Function() onShake;

  /// Tune this in range ~3.0 to 3.5 depending on desired sensitivity.
  final double threshold;

  /// Minimum time between accepted shake events.
  final Duration cooldown;

  /// Small debounce to suppress noisy rapid triggers.
  final Duration debounce;

  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _debounceTimer;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pending = false;

  void start() {
    if (_subscription != null) return;

    _subscription = accelerometerEventStream().listen(
      _onAccelerometer,
      onError: (_, __) {
        // Fail silently.
      },
    );
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final gForce = magnitude / 9.81;

    if (gForce <= threshold) return;
    if (_pending) return;

    final now = DateTime.now();
    if (now.difference(_lastShakeAt) < cooldown) return;

    _pending = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _pending = false;
      _lastShakeAt = DateTime.now();
      onShake();
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    _subscription?.cancel();
    _subscription = null;
  }
}
