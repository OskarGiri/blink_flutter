import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

/// Global toggle for the proximity feature.
///
/// When disabled, the app does not subscribe to sensor events and the overlay
/// remains hidden.
final proximityEnabledProvider =
    NotifierProvider<ProximityEnabledNotifier, bool>(
      ProximityEnabledNotifier.new,
    );

class ProximityEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool value) {
    state = value;
  }
}

/// Global proximity state:
/// - true  => near
/// - false => far (or unsupported/disabled/error)
///
/// Keeps a single notifier instance alive for the app lifetime.
final proximityStateProvider = StreamProvider<bool>((ref) {
  final enabled = ref.watch(proximityEnabledProvider);

  if (!enabled) {
    return Stream<bool>.value(false);
  }

  // Android-only behavior. iOS/web/desktop keep overlay hidden.
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return Stream<bool>.value(false);
  }

  final controller = StreamController<bool>();
  StreamSubscription<dynamic>? sensorSubscription;
  Timer? debounceTimer;

  const debounceDuration = Duration(milliseconds: 220);

  bool toNear(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value > 0;
    return false;
  }

  try {
    sensorSubscription = ProximitySensor.events.listen(
      (event) {
        final isNear = toNear(event);
        debounceTimer?.cancel();
        debounceTimer = Timer(debounceDuration, () {
          if (!controller.isClosed) {
            controller.add(isNear);
          }
        });
      },
      onError: (_, __) {
        // Fail silently and keep overlay hidden.
        if (!controller.isClosed) {
          controller.add(false);
        }
      },
    );
  } catch (_) {
    // Fail silently and keep overlay hidden.
    controller.add(false);
  }

  ref.onDispose(() {
    debounceTimer?.cancel();
    sensorSubscription?.cancel();
    controller.close();
  });

  return controller.stream;
});
