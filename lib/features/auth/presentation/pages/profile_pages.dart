// =====================================================
// FILE: lib/features/auth/presentation/pages/profile_pages.dart
// (REAL-TIME Profile tab using Hive listenable)
// =====================================================
import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_camera_avatar_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_edit_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  String _userId(WidgetRef ref) =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final token = ref.read(tokenServiceProvider);
    final session = ref.read(userSessionServiceProvider);

    ref.read(socketServiceProvider).disconnect();
    await token.removeToken();
    await session.clearSession();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.read(hiveServiceProvider);

    return ValueListenableBuilder(
      valueListenable: hive.profileListenable(),
      builder: (context, _, __) {
        final p = hive.getProfileByUserIdSync(_userId(ref));
        final name = (p?.fullName ?? "").trim().isNotEmpty
            ? p!.fullName
            : "Profile";
        final photos = p?.photos ?? const <String>[];
        final avatar = photos.isNotEmpty ? photos.first : null;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: avatar == null
                              ? null
                              : NetworkImage(avatar),
                          child: avatar == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ProfileAction(
                                icon: Icons.settings_outlined,
                                label: "Settings",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ProfileSettingsPage(),
                                    ),
                                  );
                                },
                              ),
                              _ProfileAction(
                                icon: Icons.edit_outlined,
                                label: "Edit Profile",
                                badge: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              _ProfileAction(
                                icon: Icons.camera_alt_outlined,
                                label: "Add Media",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ProfileCameraAvatarPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.logout,
                                color: AppTheme.primaryPurple,
                              ),
                              label: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool badge;
  final VoidCallback? onTap;

  const _ProfileAction({
    required this.icon,
    required this.label,
    this.badge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: AppTheme.primaryPurple, size: 28),
                ),
                if (badge)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
