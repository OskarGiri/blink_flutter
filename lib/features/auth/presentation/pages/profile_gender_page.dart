import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_dob_page.dart';
// import 'package:blink_flutter/features/profile/data/models/profile_hive_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileGenderPage extends ConsumerStatefulWidget {
  const ProfileGenderPage({super.key});

  @override
  ConsumerState<ProfileGenderPage> createState() => _ProfileGenderPageState();
}

class _ProfileGenderPageState extends ConsumerState<ProfileGenderPage> {
  static const String _userKey = "guest";

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSavedGender);
  }

  Future<void> _loadSavedGender() async {
    final hiveService = ref.read(hiveServiceProvider);
    final profile = await hiveService.getProfileByUserId(_userKey);

    if (profile != null) {
      setState(() {
        _selectedGender = profile.gender;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your gender")),
      );
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);

    // get existing profile first (so we don’t lose fullName)
    final old = await hiveService.getProfileByUserId(_userKey);

    if (old == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Full name not found. Please fill it first."),
        ),
      );
      return;
    }

    final updated = old.copyWith(gender: _selectedGender, pendingSync: true);
    await hiveService.saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gender saved locally (Hive) ✅")),
    );

    // Next step later: navigate to DOB page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Setup"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "I am a",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            RadioListTile<String>(
              title: const Text("Man"),
              value: "man",
              groupValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            RadioListTile<String>(
              title: const Text("Woman"),
              value: "woman",
              groupValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            RadioListTile<String>(
              title: const Text("Other"),
              value: "other",
              groupValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveAndContinue();
                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileDobPage()),
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
