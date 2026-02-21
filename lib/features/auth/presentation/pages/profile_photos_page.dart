// lib/features/auth/presentation/pages/profile_photos_page.dart
import 'dart:io';

import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
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
      appBar: AppBar(leading: const BackButton()),
      body: FutureBuilder<ProfileHiveModel?>(
        future: _getProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final urls = profile?.photos ?? const <String>[];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "Add Your recent\nPics",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffB43AE6),
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
                        onTap: _loading ? null : () => _pickAndUpload(index),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                                image: hasPhoto
                                    ? DecorationImage(
                                        image: NetworkImage(urls[index]),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.add, size: 18),
                                  ),
                                ),
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
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(7),
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
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("NEXT", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
