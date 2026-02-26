// FILE: lib/features/auth/presentation/widgets/profile_photos_grid.dart
// (REAL-TIME photos grid - updates instantly when Hive profile changes)
// =====================================================
import 'dart:io';

import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/photo_remote_datasource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotosGrid extends ConsumerStatefulWidget {
  const ProfilePhotosGrid({
    super.key,
    this.maxSlots = 6,
    this.crossAxisCount = 3,
    this.spacing = 10,
    this.childAspectRatio = 0.75,
    this.onChanged,
  });

  final int maxSlots;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final VoidCallback? onChanged;

  @override
  ConsumerState<ProfilePhotosGrid> createState() => _ProfilePhotosGridState();
}

class _ProfilePhotosGridState extends ConsumerState<ProfilePhotosGrid> {
  bool _busy = false;

  String _userId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  Future<void> _savePhotos(List<String> photos) async {
    final hive = ref.read(hiveServiceProvider);
    final existing = await hive.getProfileByUserId(_userId());
    if (existing == null) return;
    await hive.saveProfile(existing.copyWith(photos: photos));
  }

  Future<void> _pickAndUpload() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final remote = ref.read(photoRemoteDatasourceProvider);
      final photos = await remote.uploadPhoto(File(picked.path));
      await _savePhotos(photos);
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAt(int index) async {
    setState(() => _busy = true);
    try {
      final remote = ref.read(photoRemoteDatasourceProvider);
      final photos = await remote.deletePhotoByIndex(index);
      await _savePhotos(photos);
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hive = ref.read(hiveServiceProvider);
    final userId = _userId();

    return ValueListenableBuilder(
      valueListenable: hive.profileListenable(),
      builder: (context, _, __) {
        final p = hive.getProfileByUserIdSync(userId);
        final photos = p?.photos ?? const <String>[];

        return Stack(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.maxSlots,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: widget.spacing,
                mainAxisSpacing: widget.spacing,
                childAspectRatio: widget.childAspectRatio,
              ),
              itemBuilder: (context, i) {
                final has = i < photos.length && photos[i].trim().isNotEmpty;

                return InkWell(
                  onTap: _busy ? null : _pickAndUpload,
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                          image: has
                              ? DecorationImage(
                                  image: NetworkImage(photos[i]),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                        ),
                      ),
                      if (has)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _busy ? null : () => _deleteAt(i),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(8),
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
            if (_busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
