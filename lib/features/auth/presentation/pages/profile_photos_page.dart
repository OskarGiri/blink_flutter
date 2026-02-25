// lib/features/auth/presentation/pages/profile_photos_page.dart
import 'dart:io';

import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/data/datasources/photo_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotosPage extends ConsumerStatefulWidget {
  const ProfilePhotosPage({super.key});

  @override
  ConsumerState<ProfilePhotosPage> createState() => _ProfilePhotosPageState();
}

class _ProfilePhotosPageState extends ConsumerState<ProfilePhotosPage> {
  bool _loading = false;

  String _userId(WidgetRef ref) {
    final session = ref.read(userSessionServiceProvider);
    return session.getCurrentUserId() ?? "guest";
  }

  Future<ProfileHiveModel?> _getProfile() async {
    final hive = ref.read(hiveServiceProvider);
    return hive.getProfileByUserId(_userId(ref));
  }

  Future<void> _saveUrlsToHive(List<String> urls) async {
    final hive = ref.read(hiveServiceProvider);
    final existing = await hive.getProfileByUserId(_userId(ref));
    if (existing == null) return;

    await hive.saveProfile(existing.copyWith(photos: urls, pendingSync: false));
  }

  Future<void> _pickAndUpload(int slotIndex) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final remote = ref.read(photoRemoteDatasourceProvider);
      final urls = await remote.uploadPhoto(File(picked.path));
      await _saveUrlsToHive(urls);

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePhoto(int index) async {
    setState(() => _loading = true);
    try {
      final remote = ref.read(photoRemoteDatasourceProvider);
      final urls = await remote.deletePhotoByIndex(index);
      await _saveUrlsToHive(urls);

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _canProceed(ProfileHiveModel? p) {
    final photos = p?.photos ?? const <String>[];
    return photos.isNotEmpty;
  }

  /// ✅ Saves the onboarding fields (name/dob/gender/lookingFor) to backend MongoDB.
  /// Photos are already saved via upload endpoints.
  Future<void> _syncProfileToBackend() async {
    final hive = ref.read(hiveServiceProvider);
    final session = ref.read(userSessionServiceProvider);
    final remote = ref.read(profileRemoteDatasourceProvider);

    final userId = session.getCurrentUserId() ?? "guest";
    final p = await hive.getProfileByUserId(userId);
    if (p == null) return;

    await remote.updateMe({
      "fullName": p.fullName,
      "dob": p.dob,
      "gender": p.gender,
      "lookingFor": p.lookingFor,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: FutureBuilder<ProfileHiveModel?>(
            future: _getProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final urls = profile?.photos ?? const <String>[];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
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
                      "Add Your Photos",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Show the real you (at least 1 photo required)",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final hasPhoto =
                              index < urls.length && urls[index].isNotEmpty;

                          return InkWell(
                            onTap: _loading
                                ? null
                                : () => _pickAndUpload(index),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    image: hasPhoto
                                        ? DecorationImage(
                                            image: NetworkImage(urls[index]),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: !hasPhoto
                                        ? Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo,
                                              size: 20,
                                              color: AppTheme.primaryPurple,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                if (hasPhoto)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: _loading
                                          ? null
                                          : () => _deletePhoto(index),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade400,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_loading || !_canProceed(profile))
                            ? null
                            : () async {
                                setState(() => _loading = true);
                                try {
                                  // ✅ IMPORTANT: Save profile fields to MongoDB
                                  await _syncProfileToBackend();
                                } catch (_) {
                                  // If offline: ignore (later we can auto-sync using pendingSync)
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }

                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardShell(),
                                  ),
                                );
                              },
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
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryPurple,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                "GET STARTED",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
