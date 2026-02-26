import 'package:blink_flutter/core/navigation/app_navigator.dart';
import 'package:blink_flutter/core/navigation/dashboard_tab_provider.dart';
import 'package:blink_flutter/core/navigation/navigation_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationListener extends ConsumerWidget {
  const NavigationListener({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NavigationCommand?>(navigationCommandProvider, (prev, next) {
      if (next != NavigationCommand.goToMatches) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = appNavigatorKey.currentState;
        if (navigator == null) {
          ref.read(navigationCommandProvider.notifier).consume();
          return;
        }

        final currentTab = ref.read(dashboardTabIndexProvider);
        final canPop = navigator.canPop();

        // If already at Matches tab and no route above it, do nothing.
        if (currentTab == 1 && !canPop) {
          ref.read(navigationCommandProvider.notifier).consume();
          return;
        }

        // Close transient screens (e.g., chat/profile detail) and reveal dashboard.
        if (canPop) {
          navigator.popUntil((route) => route.isFirst);
        }

        ref.read(dashboardTabIndexProvider.notifier).setIndex(1);
        ref.read(navigationCommandProvider.notifier).consume();
      });
    });

    return const SizedBox.shrink();
  }
}
