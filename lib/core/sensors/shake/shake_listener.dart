import 'package:blink_flutter/core/sensors/shake/shake_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShakeListener extends ConsumerWidget {
  const ShakeListener({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shakeBootstrapProvider);
    return const SizedBox.shrink();
  }
}
