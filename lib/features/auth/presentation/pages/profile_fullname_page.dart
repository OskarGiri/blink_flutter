import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_gender_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileFullNamePage extends ConsumerStatefulWidget {
  const ProfileFullNamePage({super.key});

  @override
  ConsumerState<ProfileFullNamePage> createState() =>
      _ProfileFullNamePageState();
}

class _ProfileFullNamePageState extends ConsumerState<ProfileFullNamePage> {
  final TextEditingController _nameController = TextEditingController();

  static const String _userKey = "guest"; // ✅ temporary key for now

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSavedName);
  }

  Future<void> _loadSavedName() async {
    final hiveService = ref.read(hiveServiceProvider);
    final profile = await hiveService.getProfileByUserId(_userKey);

    if (profile != null) {
      _nameController.text = profile.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final fullName = _nameController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);

    // ✅ IMPORTANT: keep existing gender/dob/lookingFor if already saved
    final old = await hiveService.getProfileByUserId(_userKey);

    final ProfileHiveModel updated = old == null
        ? ProfileHiveModel(
            userId: _userKey,
            fullName: fullName,
            pendingSync: true,
          )
        : old.copyWith(fullName: fullName, pendingSync: true);

    await hiveService.saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved locally (Hive) ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My first name and last name is",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Enter your full name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveAndContinue();
                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileGenderPage(),
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
