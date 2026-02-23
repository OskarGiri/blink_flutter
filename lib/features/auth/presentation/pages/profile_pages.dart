// lib/features/profile/presentation/profile_page.dart
import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
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
        final ProfileHiveModel? p = hive.getProfileByUserIdSync(_userId(ref));

        final name = (p?.fullName ?? "").trim().isNotEmpty
            ? p!.fullName
            : "Profile";
        final photos = p?.photos ?? const <String>[];
        final avatar = photos.isNotEmpty ? photos.first : null;

        return Scaffold(
          appBar: AppBar(leading: const BackButton(), title: const Text("")),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: avatar == null
                        ? null
                        : NetworkImage(avatar),
                    child: avatar == null
                        ? const Icon(Icons.person, size: 54)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ProfileAction(
                          icon: Icons.settings,
                          label: "Settings",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileSettingsPage(),
                              ),
                            );
                          },
                        ),
                        _ProfileAction(
                          icon: Icons.edit,
                          label: "Edit profile",
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
                          icon: Icons.camera_alt,
                          label: "Add media",
                          red: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileCameraAvatarPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _logout(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                  ),
                ],
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
  final bool red;
  final VoidCallback? onTap;

  const _ProfileAction({
    required this.icon,
    required this.label,
    this.badge = false,
    this.red = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = red ? Colors.redAccent : Colors.grey.shade700;

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
                  radius: 28,
                  backgroundColor: red
                      ? Colors.redAccent.withOpacity(0.12)
                      : Colors.grey.shade200,
                  child: Icon(icon, color: color),
                ),
                if (badge)
                  const Positioned(
                    top: 2,
                    right: 2,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
