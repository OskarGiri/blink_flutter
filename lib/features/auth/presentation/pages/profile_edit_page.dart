import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/profile_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/widgets/profile_photos_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();

  DateTime? _dob;
  String? _gender;
  String? _lookingFor;
  bool _loading = true;
  bool _saving = false;

  String _userId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHiveFirstThenSync);
  }

  @override
  void dispose() {
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _loadHiveFirstThenSync() async {
    final hive = ref.read(hiveServiceProvider);

    // 1) Hive first
    final local = await hive.getProfileByUserId(_userId());
    if (local != null) _apply(local);

    setState(() => _loading = false);

    // 2) Sync from API if online
    final online = await ref.read(networkInfoProvider).isConnected;
    if (!online) return;

    try {
      final remote = ref.read(profileRemoteDatasourceProvider);
      final json = await remote.getMe();

      final refreshed = ProfileHiveModel(
        userId: _userId(),
        fullName: (json["fullName"] ?? "").toString(),
        dob: json["dob"]?.toString(),
        gender: json["gender"]?.toString(),
        lookingFor: json["lookingFor"]?.toString(),
        photos: (json["photos"] is List)
            ? (json["photos"] as List).map((e) => e.toString()).toList()
            : const [],
        pendingSync: false,
      );

      await hive.saveProfile(refreshed);
      if (!mounted) return;
      _apply(refreshed);
    } catch (_) {
      // keep local
    }
  }

  void _apply(ProfileHiveModel p) {
    setState(() {
      _fullName.text = p.fullName.toString();
      _dob = _parseDob(p.dob);
      _gender = _safeDropdownValue(p.gender?.toString(), const [
        "male",
        "female",
        "other",
      ]);
      _lookingFor = _safeDropdownValue(p.lookingFor?.toString(), const [
        "men",
        "women",
        "everyone",
      ]);
    });
  }

  String? _safeDropdownValue(String? value, List<String> allowed) {
    if (value == null) return null;
    final v = value.trim().toLowerCase();
    return allowed.contains(v) ? v : null;
  }

  DateTime? _parseDob(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  bool _is18Plus(DateTime dob) {
    final now = DateTime.now();
    var years = now.year - dob.year;
    final hadBirthday =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthday) years -= 1;
    return years >= 18;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final dob = _dob;
    if (dob == null) {
      _snack("Select date of birth");
      return;
    }
    if (!_is18Plus(dob)) {
      _snack("You must be 18+");
      return;
    }
    if (_gender == null || _gender!.isEmpty) {
      _snack("Select gender");
      return;
    }
    if (_lookingFor == null || _lookingFor!.isEmpty) {
      _snack("Select looking for");
      return;
    }

    setState(() => _saving = true);
    try {
      final hive = ref.read(hiveServiceProvider);
      final existing = await hive.getProfileByUserId(_userId());

      // ✅ update Hive immediately (offline friendly)
      final updatedLocal = ProfileHiveModel(
        userId: _userId(),
        fullName: _fullName.text.trim(),
        dob: dob.toIso8601String(),
        gender: _gender,
        lookingFor: _lookingFor,
        photos: existing?.photos ?? const [],
        pendingSync: true,
      );
      await hive.saveProfile(updatedLocal);

      // ✅ sync if online
      final online = await ref.read(networkInfoProvider).isConnected;
      if (online) {
        final remote = ref.read(profileRemoteDatasourceProvider);
        await remote.updateMe({
          "fullName": updatedLocal.fullName,
          "dob": updatedLocal.dob,
          "gender": updatedLocal.gender,
          "lookingFor": updatedLocal.lookingFor,
        });

        final json = await remote.getMe();
        final refreshed = ProfileHiveModel(
          userId: _userId(),
          fullName: (json["fullName"] ?? "").toString(),
          dob: json["dob"]?.toString(),
          gender: json["gender"]?.toString(),
          lookingFor: json["lookingFor"]?.toString(),
          photos: (json["photos"] is List)
              ? (json["photos"] as List).map((e) => e.toString()).toList()
              : const [],
          pendingSync: false,
        );
        await hive.saveProfile(refreshed);
      }

      if (!mounted) return;
      _snack("Profile saved");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack("Save failed: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Photos",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      ProfilePhotosGrid(),
                      SizedBox(height: 8),
                      Text(
                        "First photo is your avatar.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullName,
                          decoration: const InputDecoration(
                            labelText: "Full name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.isEmpty) return "Name is required";
                            if (s.length < 2) return "Too short";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _DobPicker(
                          value: _dob,
                          onChanged: (d) => setState(() => _dob = d),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "male",
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: "female",
                              child: Text("Female"),
                            ),
                            DropdownMenuItem(
                              value: "other",
                              child: Text("Other"),
                            ),
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _lookingFor,
                          decoration: const InputDecoration(
                            labelText: "Looking for",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: "men", child: Text("Men")),
                            DropdownMenuItem(
                              value: "women",
                              child: Text("Women"),
                            ),
                            DropdownMenuItem(
                              value: "everyone",
                              child: Text("Everyone"),
                            ),
                          ],
                          onChanged: (v) => setState(() => _lookingFor = v),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DobPicker extends StatelessWidget {
  const _DobPicker({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final display = value == null
        ? "Select"
        : "${value!.year}-${value!.month.toString().padLeft(2, "0")}-${value!.day.toString().padLeft(2, "0")}";

    return InkWell(
      onTap: () async {
        final initial = value ?? DateTime(now.year - 20, now.month, now.day);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900, 1, 1),
          lastDate: DateTime(now.year - 18, now.month, now.day),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Date of birth",
          border: OutlineInputBorder(),
        ),
        child: Text(display),
      ),
    );
  }
}
