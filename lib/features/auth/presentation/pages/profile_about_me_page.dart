import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileAboutMePage extends ConsumerStatefulWidget {
  const ProfileAboutMePage({super.key});

  @override
  ConsumerState<ProfileAboutMePage> createState() => _ProfileAboutMePageState();
}

class _ProfileAboutMePageState extends ConsumerState<ProfileAboutMePage> {
  final TextEditingController _bioController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  String _userId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? 'guest';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final hive = ref.read(hiveServiceProvider);
    final profile = await hive.getProfileByUserId(_userId());
    _bioController.text = (profile?.bio ?? '').trim();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveBio() async {
    final bio = _bioController.text.trim();
    if (bio.length > 500) {
      _showSnack('Max 500 characters');
      return;
    }

    setState(() => _saving = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userId());
      if (existing == null) {
        _showSnack('Profile not found');
        return;
      }

      final updatedLocal = existing.copyWith(bio: bio, pendingSync: true);
      await hive.saveProfile(updatedLocal);

      final online = await ref.read(networkInfoProvider).isConnected;
      if (online) {
        final remote = ref.read(profileRemoteDatasourceProvider);
        await remote.updateMe({'bio': bio});
        await hive.saveProfile(updatedLocal.copyWith(pendingSync: false));
      }

      if (!mounted) return;
      _showSnack('About Me saved');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a short bio to improve your profile.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: TextField(
                            controller: _bioController,
                            maxLength: 500,
                            maxLines: 9,
                            decoration: const InputDecoration(
                              labelText: 'About Me',
                              hintText: 'Tell people about yourself...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveBio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryPurple,
                            disabledBackgroundColor: Colors.white.withOpacity(
                              0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                            elevation: 4,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryPurple,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'SAVE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
