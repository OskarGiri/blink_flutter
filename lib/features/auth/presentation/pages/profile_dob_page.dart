import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_lookingfor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDobPage extends ConsumerStatefulWidget {
  const ProfileDobPage({super.key});

  @override
  ConsumerState<ProfileDobPage> createState() => _ProfileDobPageState();
}

class _ProfileDobPageState extends ConsumerState<ProfileDobPage> {
  static const String _userKey = "guest";

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSavedDob);
  }

  Future<void> _loadSavedDob() async {
    final hiveService = ref.read(hiveServiceProvider);
    final profile = await hiveService.getProfileByUserId(_userKey);

    if (profile?.dob != null) {
      setState(() {
        _selectedDate = DateTime.tryParse(profile!.dob!);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final lastAllowed = DateTime(now.year - 18, now.month, now.day);
    final initial = _selectedDate ?? lastAllowed;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: lastAllowed, // ✅ cannot pick under 18
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _format(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  Future<void> _saveAndContinue() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth")),
      );
      return;
    }

    final now = DateTime.now();
    final lastAllowed = DateTime(now.year - 18, now.month, now.day);

    if (_selectedDate!.isAfter(lastAllowed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be at least 18 years old")),
      );
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);
    final old = await hiveService.getProfileByUserId(_userKey);

    if (old == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile not found. Please start from name page."),
        ),
      );
      return;
    }

    final updated = old.copyWith(
      dob: _format(_selectedDate!),
      pendingSync: true,
    );
    await hiveService.saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("DOB saved locally (Hive) ✅")));

    // Next step later: Looking For page
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
              "My birthday is",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Select date"
                      : _format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
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
                    MaterialPageRoute(
                      builder: (_) => const ProfileLookingForPage(),
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
