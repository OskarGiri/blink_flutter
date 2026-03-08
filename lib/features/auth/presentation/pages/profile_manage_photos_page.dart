import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/presentation/widgets/profile_photos_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileManagePhotosPage extends ConsumerWidget {
  const ProfileManagePhotosPage({super.key});

  String _userId(WidgetRef ref) =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.read(hiveServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Photos")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ValueListenableBuilder(
            valueListenable: hive.profileListenable(),
            builder: (context, _, __) {
              final profile = hive.getProfileByUserIdSync(_userId(ref));
              final photos = profile?.photos ?? const <String>[];
              final count = photos.where((p) => p.trim().isNotEmpty).length;
              final needed = (4 - count).clamp(0, 4);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "Add at least 4 photos",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    needed == 0
                        ? "Great! Your photo section is complete."
                        : "Add $needed more photo${needed == 1 ? '' : 's'} to complete your profile.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ProfilePhotosGrid(),
                          SizedBox(height: 10),
                          Text(
                            "Tap any slot to add photo. First photo is your avatar.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
