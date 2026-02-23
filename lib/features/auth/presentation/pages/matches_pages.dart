import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/features/auth/data/datasources/matches_remote_datasources_providers.dart';
import 'package:blink_flutter/features/auth/presentation/pages/chat_pages.dart';
import 'package:blink_flutter/features/auth/presentation/providers/matches_refresh_trigger_provider.dart';
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

  late final ProviderSubscription<int> _refreshSub;

  @override
  void initState() {
    super.initState();

    _refreshSub = ref.listenManual<int>(
      matchesRefreshTriggerProvider,
      (_, __) => _load(),
    );

    Future.microtask(_load);
  }

  @override
  void dispose() {
    _refreshSub.close();
    super.dispose();
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
    final Widget body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? _ErrorState(message: _error!, onRetry: _load)
        : _matches.isEmpty
        ? const _EmptyState()
        : RefreshIndicator(
            onRefresh: _load,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: _matches.length,
                itemBuilder: (context, i) => _MatchTile(
                  match: _matches[i],
                  onTap: (matchId, title, avatarUrl) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          matchId: matchId,
                          title: title,
                          avatarUrl: avatarUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(title: const Text("Matches")),
      body: body,
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.onTap});

  final Map<String, dynamic> match;
  final void Function(String matchId, String title, String? avatarUrl) onTap;

  @override
  Widget build(BuildContext context) {
    final matchId = (match["id"] ?? "").toString();

    final other = (match["otherUser"] is Map)
        ? Map<String, dynamic>.from(match["otherUser"])
        : <String, dynamic>{};

    final name = (other["fullName"]?.toString().trim().isNotEmpty == true)
        ? other["fullName"].toString()
        : (other["username"]?.toString() ?? "User");

    final photos = (other["photos"] is List)
        ? List<String>.from(other["photos"])
        : <String>[];

    final avatarUrl = photos.isNotEmpty ? photos.first : null;

    // ✅ NEW: last message preview (backend must return match["lastMessage"])
    final last = (match["lastMessage"] is Map)
        ? Map<String, dynamic>.from(match["lastMessage"])
        : null;

    final lastText = last == null ? "" : (last["text"] ?? "").toString().trim();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(matchId, name, avatarUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _TileImage(url: avatarUrl),
            const _BottomGradient(),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (lastText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u == null || u.isEmpty) {
      return Container(
        color: const Color(0xFFEAEAEA),
        child: const Center(
          child: Icon(Icons.person, size: 64, color: Color(0xFF9E9E9E)),
        ),
      );
    }

    return Image.network(
      u,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFEAEAEA),
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Color(0xFF9E9E9E)),
        ),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFEAEAEA),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 110,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0xAA000000)],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.favorite_border, size: 64, color: Color(0xFFBDBDBD)),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No matches yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Keep swiping — your matches will appear here.',
            style: TextStyle(color: Color(0xFF757575)),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 56),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => onRetry(),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
