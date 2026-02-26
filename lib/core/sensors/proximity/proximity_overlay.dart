import 'package:blink_flutter/core/sensors/proximity/proximity_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProximityOverlay extends ConsumerWidget {
  const ProximityOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(proximityEnabledProvider);
    if (!enabled) return const SizedBox.shrink();

    final isNear = ref
        .watch(proximityStateProvider)
        .maybeWhen(data: (value) => value, orElse: () => false);

    if (!isNear) return const SizedBox.shrink();

    return Positioned.fill(
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            ModalBarrier(color: Colors.black54, dismissible: false),
            Center(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 44,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your phone is too close',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Move the phone away to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
