// lib/features/dashboard/presentation/dashboard_shell.dart

import 'package:blink_flutter/features/auth/presentation/pages/discovery_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/matches_pages.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_pages.dart';
import 'package:flutter/material.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DiscoveryPage(), // ✅ this IS your swipe dashboard
      const MatchesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }
}
