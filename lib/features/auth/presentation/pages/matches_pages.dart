import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/features/auth/data/datasources/matches_remote_datasources_providers.dart';
import 'package:blink_flutter/features/auth/presentation/pages/chat_pages.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesPage extends ConsumerStatefulWidget {
  const MatchesPage({super.key});

  @override
  ConsumerState<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<MatchesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final net = ref.read(networkInfoProvider);
      final connected = await net.isConnected;

      if (!connected) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = "Offline: matches need internet (for now).";
          _matches = [];
        });
        return;
      }

      final api = ref.read(matchesRemoteDatasourceProvider);
      final list = await api.getMatches();

      if (!mounted) return;
      setState(() {
        _matches = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Failed to load matches: $e";
        _matches = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Matches"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _matches.isEmpty
          ? const Center(child: Text("No matches yet"))
          : ListView.separated(
              itemCount: _matches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = _matches[i];
                final matchId = (m["id"] ?? "").toString();

                final other = (m["otherUser"] is Map)
                    ? Map<String, dynamic>.from(m["otherUser"])
                    : <String, dynamic>{};

                final name =
                    (other["fullName"]?.toString().trim().isNotEmpty == true)
                    ? other["fullName"].toString()
                    : (other["username"]?.toString() ?? "User");

                final photos = (other["photos"] is List)
                    ? List<String>.from(other["photos"])
                    : <String>[];

                final avatarUrl = photos.isNotEmpty ? photos.first : null;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: avatarUrl == null
                        ? null
                        : NetworkImage(avatarUrl),
                    child: avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(name),
                  subtitle: const Text("Tap to chat"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          matchId: matchId,
                          title: name,
                          avatarUrl: avatarUrl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
