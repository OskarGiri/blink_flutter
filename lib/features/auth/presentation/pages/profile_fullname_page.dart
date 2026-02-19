import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_dob_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileFullNamePage extends ConsumerStatefulWidget {
  const ProfileFullNamePage({super.key});

  @override
  ConsumerState<ProfileFullNamePage> createState() =>
      _ProfileFullNamePageState();
}

class _ProfileFullNamePageState extends ConsumerState<ProfileFullNamePage> {
  final TextEditingController _fullNameController = TextEditingController();
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
    if (profile != null) {
      _fullNameController.text = profile.fullName.toString();
    }
  }

  Future<void> _saveAndNext() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter full name")));
      return;
    }

    setState(() => _loading = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userKey(ref));

      final updated = ProfileHiveModel(
        userId: _userKey(ref),
        fullName: fullName,
        dob: existing?.dob,
        gender: existing?.gender,
        lookingFor: existing?.lookingFor,
        pendingSync: true,
      );

      await hive.saveProfile(updated);

      if (!mounted) return;
      Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ProfileDobPage()),
);

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Full Name")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: "Full name"),
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
