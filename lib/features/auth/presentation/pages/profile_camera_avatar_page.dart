import 'dart:io';

import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/photo_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCameraAvatarPage extends ConsumerStatefulWidget {
  const ProfileCameraAvatarPage({super.key});

  @override
  ConsumerState<ProfileCameraAvatarPage> createState() =>
      _ProfileCameraAvatarPageState();
}

class _ProfileCameraAvatarPageState
    extends ConsumerState<ProfileCameraAvatarPage> {
  bool _busy = false;

  String _userId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  Future<void> _takePhotoAndSetAvatar() async {
    final picker = ImagePicker();

    final shot = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );

    if (shot == null) return;

    setState(() => _busy = true);
    try {
      final remote = ref.read(photoRemoteDatasourceProvider);

      // Upload to backend -> returns updated photos list
      final photos = await remote.uploadPhoto(File(shot.path));

      // Make the latest uploaded photo the first (avatar) locally
      final reordered = _moveLastToFirst(photos);

      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userId());
      if (existing != null) {
        await hive.saveProfile(existing.copyWith(photos: reordered));
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camera upload failed: $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<String> _moveLastToFirst(List<String> photos) {
    if (photos.length <= 1) return photos;
    final last = photos.last;
    final rest = photos.sublist(0, photos.length - 1);
    return [last, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take profile photo")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _busy ? null : _takePhotoAndSetAvatar,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_busy ? "Uploading..." : "Open Camera"),
            ),
          ),
        ),
      ),
    );
  }
}
