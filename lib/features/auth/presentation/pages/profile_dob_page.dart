import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "When Were You Born?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You must be 18+ to use Blink",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickDob,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingMedium,
                          vertical: AppTheme.paddingMedium,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _dob == null
                                  ? AppTheme.darkGrey.withOpacity(0.6)
                                  : AppTheme.primaryPurple,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dob == null
                                    ? "Select your date of birth"
                                    : _dob!
                                          .toLocal()
                                          .toString()
                                          .split(' ')
                                          .first,
                                style: TextStyle(
                                  color: _dob == null
                                      ? AppTheme.darkGrey.withOpacity(0.6)
                                      : AppTheme.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveAndNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryPurple,
                      disabledBackgroundColor: Colors.white.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _loading ? "Saving..." : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
