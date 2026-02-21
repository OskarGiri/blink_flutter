import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
// import 'package:blink_flutter/features/auth/presentation/pages/dashboard_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_photos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileLookingForPage extends ConsumerStatefulWidget {
  const ProfileLookingForPage({super.key});

  @override
  ConsumerState<ProfileLookingForPage> createState() =>
      _ProfileLookingForPageState();
}

class _ProfileLookingForPageState extends ConsumerState<ProfileLookingForPage> {
  String? _lookingFor;
  bool _loading = false;

  String _userKey(WidgetRef ref) {
    final session = ref.read(userSessionServiceProvider);
    return session.getCurrentUserId() ?? "guest";
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadExisting);
  }

  Future<void> _loadExisting() async {
    final hive = ref.read(hiveServiceProvider);
    final profile = await hive.getProfileByUserId(_userKey(ref));
    final lf = profile?.lookingFor;

    if (lf != null && lf.toString().trim().isNotEmpty) {
      setState(() => _lookingFor = lf.toString());
    }
  }

  Future<void> _saveAndFinish() async {
    final lookingFor = (_lookingFor ?? "").trim();
    if (lookingFor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose looking for")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userKey(ref));

      final fullName = (existing?.fullName ?? "").trim();
      if (fullName.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final updated = ProfileHiveModel(
        userId: _userKey(ref),
        fullName: fullName,
        dob: existing?.dob,
        gender: existing?.gender,
        lookingFor: lookingFor,
        pendingSync: true,
      );

      await hive.saveProfile(updated);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePhotosPage()),
      );

      // Later we will route to Discovery, but dashboard is fine for Step 1 completion.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Looking For")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<String>(
              value: "men",
              groupValue: _lookingFor,
              title: const Text("Men"),
              onChanged: (v) => setState(() => _lookingFor = v),
            ),
            RadioListTile<String>(
              value: "women",
              groupValue: _lookingFor,
              title: const Text("Women"),
              onChanged: (v) => setState(() => _lookingFor = v),
            ),
            RadioListTile<String>(
              value: "everyone",
              groupValue: _lookingFor,
              title: const Text("Everyone"),
              onChanged: (v) => setState(() => _lookingFor = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _saveAndFinish,
              child: Text(_loading ? "Saving..." : "Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
