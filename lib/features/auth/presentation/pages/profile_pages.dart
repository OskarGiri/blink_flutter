// =====================================================
// FILE: lib/features/auth/presentation/pages/profile_pages.dart
// (Tinder-like Profile Design with Profile Completion)
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

  int _calculateProfileCompletion(dynamic profile) {
    int score = 0;

    if (profile != null) {
      // Full name: 25%
      if ((profile.fullName ?? "").toString().trim().isNotEmpty) score += 25;

      // DOB: 25%
      if ((profile.dob ?? "").toString().trim().isNotEmpty) score += 25;

      // Gender: 25%
      if ((profile.gender ?? "").toString().trim().isNotEmpty) score += 25;

      // Photos (4+): 25%
      final photos = profile.photos as List?;
      if (photos != null && photos.length >= 4) score += 25;

      // Bio/About Me: +20% bonus
      if ((profile.bio ?? "").toString().trim().isNotEmpty) score += 20;

      // Verification: +8% bonus (can be added later when verification is implemented)
      // score += 8;
    }

    return score.clamp(0, 100);
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
            : "User";
        final photos = p?.photos ?? const <String>[];
        final avatar = photos.isNotEmpty ? photos.first : null;
        final completion = _calculateProfileCompletion(p);

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
                        // ✅ Header: Avatar, Name, Settings, Edit Profile
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              // Settings gear button (top right)
                              Align(
                                alignment: Alignment.topRight,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ProfileSettingsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Avatar
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: avatar == null
                                    ? null
                                    : NetworkImage(avatar),
                                child: avatar == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              // Name with verification badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.lightBlueAccent,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Edit Profile button
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const EditProfilePage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text(
                                    "Edit profile",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ✅ Profile Completion Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Completion percentage and progress bar row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade400,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "$completion%",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: completion / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade400
                                            .withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Completion text
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Complete your profile to be seen by more people!",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ✅ Enhancement Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              _EnhancementCard(
                                icon: Icons.photo_outlined,
                                title: "Add at least 4 photos",
                                bonus: "+28%",
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
                              const SizedBox(height: 10),
                              _EnhancementCard(
                                icon: Icons.edit_note_outlined,
                                title: "Add \"About Me\"",
                                bonus: "+20%",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              _EnhancementCard(
                                icon: Icons.verified_outlined,
                                title: "Get verified",
                                bonus: "+8%",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ✅ Feature Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _FeatureButton(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFF0066FF),
                                  count: "0",
                                  label: "Super Likes",
                                  actionLabel: "GET MORE",
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FeatureButton(
                                  icon: Icons.bolt,
                                  iconColor: const Color(0xFFAA00FF),
                                  isBoost: true,
                                  label: "My Boosts",
                                  actionLabel: "GET MORE",
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FeatureButton(
                                  icon: Icons.favorite,
                                  iconColor: Colors.pink.shade400,
                                  label: "Subscriptions",
                                  actionLabel: "GET MORE",
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ Premium Subscription Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with badge and upgrade button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            "🔥",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            "tinder",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "GOLD",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "UPGRADE",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "What's Included",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Features table
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "See Who Likes You",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Free",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.amber.shade700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Top Picks",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Free",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.amber.shade700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Free Super Likes",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Free",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.amber.shade700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ✅ Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryPurple,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
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

// ✅ Enhancement Card Widget
class _EnhancementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String bonus;
  final VoidCallback onTap;

  const _EnhancementCard({
    required this.icon,
    required this.title,
    required this.bonus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.pink.shade400, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.pink.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bonus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.add, size: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ✅ Feature Action Button Widget
class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? count;
  final bool isBoost;
  final String label;
  final String actionLabel;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.iconColor,
    this.count,
    this.isBoost = false,
    required this.label,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            if (count != null)
              Text(
                count!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            if (!isBoost) const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              actionLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
