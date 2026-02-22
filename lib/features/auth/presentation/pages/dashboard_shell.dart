import 'package:blink_flutter/core/api/api_config.dart';
import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/presentation/pages/discovery_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/matches_pages.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_pages.dart';
import 'package:blink_flutter/features/auth/presentation/providers/matches_refresh_trigger_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _index = 0;
  bool _socketConnectedOnce = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token = ref.read(userSessionServiceProvider).getToken() ?? '';
      if (token.isEmpty) return;

      ref.read(socketServiceProvider).connect(
            baseUrl: ApiConfig.socketBaseUrl,
            token: token,
          );

      _socketConnectedOnce = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for match:new -> refresh matches
    ref.listen(matchNewStreamProvider, (prev, next) {
      next.whenData((_) {
        ref.read(matchesRefreshTriggerProvider.notifier).state++;
      });
    });

    // Listen for message:new -> refresh matches (preview later)
    ref.listen(messageNewStreamProvider, (prev, next) {
      next.whenData((_) {
        ref.read(matchesRefreshTriggerProvider.notifier).state++;
      });
    });

    // If user logs out/in without restarting app, reconnect once token appears
    if (!_socketConnectedOnce) {
      final token = ref.read(userSessionServiceProvider).getToken() ?? '';
      if (token.isNotEmpty) {
        ref.read(socketServiceProvider).connect(
              baseUrl: ApiConfig.socketBaseUrl,
              token: token,
            );
        _socketConnectedOnce = true;
      }
    }

    final pages = <Widget>[
      const DiscoveryPage(),
      const MatchesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) {
          setState(() => _index = v);

          // Matches tab open -> refresh
          if (v == 1) {
            ref.read(matchesRefreshTriggerProvider.notifier).state++;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }
}