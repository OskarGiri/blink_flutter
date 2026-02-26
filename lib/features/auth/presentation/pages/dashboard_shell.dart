import 'dart:math' show min;
import 'package:blink_flutter/core/navigation/dashboard_tab_provider.dart';
import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/realtime/socket_service.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/presentation/pages/discovery_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/matches_pages.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  final _pages = const [DiscoveryPage(), MatchesPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();

    // ✅ Initialize socket connection when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(dashboardTabIndexProvider.notifier)
          .setIndex(widget.initialIndex);
      _initializeSocket();
    });
  }

  void _initializeSocket() {
    final socketService = ref.read(socketServiceProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final token = userSession.getToken();

    debugPrint(
      "🔍 Socket init check - Token: ${token != null ? '✅ present' : '❌ missing'}",
    );
    debugPrint("🔍 Already connected: ${socketService.isConnected}");

    if (token == null || token.isEmpty) {
      debugPrint(
        "⚠️ No token available for socket connection - user may not be properly logged in",
      );
      return;
    }

    if (socketService.isConnected) {
      debugPrint("✅ Socket already connected, skipping re-initialization");
      return;
    }

    try {
      // Connect to backend socket.io server
      // Use 10.0.2.2 for Android emulator, localhost for other platforms
      const baseUrl = 'http://10.0.2.2:3000';
      debugPrint(
        "🔗 Connecting socket to: $baseUrl with token: ${token.substring(0, min(10, token.length))}...",
      );

      socketService.connect(baseUrl: baseUrl, token: token);
      debugPrint("✅ Socket connection initialized successfully");
    } catch (e) {
      debugPrint("❌ Socket initialization failed with error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(dashboardTabIndexProvider);

    return Scaffold(
      body: _pages[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) =>
                ref.read(dashboardTabIndexProvider.notifier).setIndex(i),
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryPurple,
            unselectedItemColor: AppTheme.darkGrey,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppTheme.primaryPurple.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_fire_department_rounded, size: 26),
                ),
                label: "Discover",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: index == 1
                        ? AppTheme.primaryPurple.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.favorite_outline_rounded, size: 26),
                ),
                label: "Matches",
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: index == 2
                        ? AppTheme.primaryPurple.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _LiveProfileNavIcon(isSelected: index == 2),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveProfileNavIcon extends ConsumerWidget {
  final bool isSelected;
  const _LiveProfileNavIcon({this.isSelected = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.read(hiveServiceProvider);
    final userId =
        ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

    return ValueListenableBuilder(
      valueListenable: hive.profileListenable(),
      builder: (context, _, __) {
        final p = hive.getProfileByUserIdSync(userId);
        final photos = p?.photos ?? const <String>[];
        final avatar = photos.isNotEmpty ? photos.first : null;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: CircleAvatar(
            radius: 10,
            backgroundImage: avatar == null ? null : NetworkImage(avatar),
            child: avatar == null ? const Icon(Icons.person, size: 14) : null,
          ),
        );
      },
    );
  }
}
