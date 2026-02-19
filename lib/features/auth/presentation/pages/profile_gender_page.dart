import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_lookingfor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileGenderPage extends ConsumerStatefulWidget {
  const ProfileGenderPage({super.key});

  @override
  ConsumerState<ProfileGenderPage> createState() => _ProfileGenderPageState();
}

class _ProfileGenderPageState extends ConsumerState<ProfileGenderPage> {
  String? _gender;
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
    final g = profile?.gender;

    if (g != null && g.toString().trim().isNotEmpty) {
      setState(() => _gender = g.toString());
    }
  }

  Future<void> _saveAndNext() async {
    final gender = (_gender ?? "").trim();
    if (gender.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please choose gender")));
      return;
    }

    setState(() => _loading = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userKey(ref));

      final fullName = (existing?.fullName ?? "").trim();
      if (fullName.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // back to DOB or FullName depending your flow
        return;
      }

      final updated = ProfileHiveModel(
        userId: _userKey(ref),
        fullName: fullName,
        dob: existing?.dob,
        gender: gender,
        lookingFor: existing?.lookingFor,
        pendingSync: true,
      );

      await hive.saveProfile(updated);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileLookingForPage()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gender")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<String>(
              value: "male",
              groupValue: _gender,
              title: const Text("Male"),
              onChanged: (v) => setState(() => _gender = v),
            ),
            RadioListTile<String>(
              value: "female",
              groupValue: _gender,
              title: const Text("Female"),
              onChanged: (v) => setState(() => _gender = v),
            ),
            RadioListTile<String>(
              value: "other",
              groupValue: _gender,
              title: const Text("Other"),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _saveAndNext,
              child: Text(_loading ? "Saving..." : "Next"),
            ),
          ],
        ),
      ),
    );
  }
}
