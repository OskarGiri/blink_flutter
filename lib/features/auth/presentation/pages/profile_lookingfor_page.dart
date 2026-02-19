import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileLookingForPage extends ConsumerStatefulWidget {
  const ProfileLookingForPage({super.key});

  @override
  ConsumerState<ProfileLookingForPage> createState() =>
      _ProfileLookingForPageState();
}

class _ProfileLookingForPageState extends ConsumerState<ProfileLookingForPage> {
  static const String _userKey = "guest";

  String? _selected;

  final List<Map<String, String>> _options = const [
    {"key": "long_term", "label": "Long-term relationship"},
    {"key": "short_term", "label": "Short-term relationship"},
    {"key": "friendship", "label": "Friendship"},
    {"key": "figuring_out", "label": "Still figuring it out"},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSaved);
  }

  Future<void> _loadSaved() async {
    final hiveService = ref.read(hiveServiceProvider);
    final profile = await hiveService.getProfileByUserId(_userKey);
    if (profile?.lookingFor != null) {
      setState(() => _selected = profile!.lookingFor);
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select one option")));
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

    final updated = old.copyWith(lookingFor: _selected, pendingSync: true);
    await hiveService.saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved locally (Hive) ✅")));

    // Next step: Interests page (Step 2.7)
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
              "I am looking for",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ..._options.map((o) {
              return RadioListTile<String>(
                title: Text(o["label"]!),
                value: o["key"]!,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
              );
            }),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
