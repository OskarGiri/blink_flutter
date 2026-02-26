// lib/features/auth/presentation/pages/splash_page.dart
import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/dashboard_shell.dart';
import 'package:blink_flutter/features/auth/presentation/pages/onboarding_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_fullname_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    Future.microtask(_route);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isProfileComplete(ProfileHiveModel? profile) {
    final fullName = (profile?.fullName ?? '').toString().trim();
    final gender = (profile?.gender ?? '').toString().trim();
    final dob = (profile?.dob ?? '').toString().trim();
    final lookingFor = (profile?.lookingFor ?? '').toString().trim();
    final photos = profile?.photos ?? const <String>[];

    return fullName.isNotEmpty &&
        gender.isNotEmpty &&
        dob.isNotEmpty &&
        lookingFor.isNotEmpty &&
        photos.isNotEmpty;
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final tokenService = ref.read(tokenServiceProvider);
    final session = ref.read(userSessionServiceProvider);
    final hive = ref.read(hiveServiceProvider);
    final network = ref.read(networkInfoProvider);
    final remote = ref.read(profileRemoteDatasourceProvider);

    final token = await tokenService.getToken();
    final isLoggedInOffline = session.isLoggedIn();

    if (token == null && !isLoggedInOffline) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final userId = session.getCurrentUserId() ?? "guest";

    final connected = await network.isConnected;
    if (connected) {
      try {
        final data = await remote.getMe();
        final cached = await hive.getProfileByUserId(userId);

        final photos = (data["photos"] is List)
            ? (data["photos"] as List).map((e) => e.toString()).toList()
            : (cached?.photos ?? const <String>[]);

        final updated = ProfileHiveModel(
          userId: userId,
          fullName: (data["fullName"] ?? cached?.fullName ?? "").toString(),
          dob: (data["dob"] ?? cached?.dob ?? "").toString(),
          gender: (data["gender"] ?? cached?.gender ?? "").toString(),
          lookingFor: (data["lookingFor"] ?? cached?.lookingFor ?? "")
              .toString(),
          photos: photos,
          pendingSync: false,
        );

        await hive.saveProfile(updated);
      } catch (_) {
        // ignore API errors -> fallback to Hive
      }
    }

    final profile = await hive.getProfileByUserId(userId);
    final complete = _isProfileComplete(profile);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            complete ? const DashboardShell() : const ProfileFullNamePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Spacing
                SizedBox(height: size.height * 0.15),

                // Logo and App Name with Animations
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Animated Icon/Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              size: 64,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App Name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ).createShader(bounds),
                          child: const Text(
                            'Blink',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tagline at the bottom
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Text(
                          '"Meet your',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Text(
                          'match"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Loading indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
