import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_gender_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDobPage extends ConsumerStatefulWidget {
  const ProfileDobPage({super.key});

  @override
  ConsumerState<ProfileDobPage> createState() => _ProfileDobPageState();
}

class _ProfileDobPageState extends ConsumerState<ProfileDobPage> {
  DateTime? _dob;
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
    final dobStr = profile?.dob;

    if (dobStr != null && dobStr.toString().trim().isNotEmpty) {
      final parsed = DateTime.tryParse(dobStr.toString());
      if (parsed != null) setState(() => _dob = parsed);
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;

    // If birthday hasn't happened yet this year, subtract 1
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();

    // ✅ Prevent selecting dates that make user under 18
    final maxDob = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: maxDob, // ✅ Under-18 cannot be picked
    );

    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _saveAndNext() async {
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date of birth")),
      );
      return;
    }

    // ✅ 18+ check (extra safety even though picker restricts it)
    final age = _calculateAge(_dob!);
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be 18+ to use this app.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userKey(ref));

      // fullName is required in your ProfileHiveModel
      final fullName = (existing?.fullName ?? "").trim();
      if (fullName.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // go back to Full Name page
        return;
      }

      final updated = ProfileHiveModel(
        userId: _userKey(ref),
        fullName: fullName,
        dob: _dob!.toIso8601String(),
        gender: existing?.gender,
        lookingFor: existing?.lookingFor,
        pendingSync: true,
      );

      await hive.saveProfile(updated);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileGenderPage()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Date of Birth")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dob == null
                        ? "No date selected"
                        : _dob!.toLocal().toString().split(' ').first,
                  ),
                ),
                TextButton(onPressed: _pickDob, child: const Text("Pick")),
              ],
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
