// lib/features/auth/presentation/pages/splash_page.dart
import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_route);
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 109, 181),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Blink Dating",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
