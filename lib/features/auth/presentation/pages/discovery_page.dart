// lib/features/discovery/presentation/discovery_page.dart
import 'dart:math' as math;

import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/discovery_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_datasource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  Offset _dragOffset = Offset.zero;

  String _userId() => ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final hive = ref.read(hiveServiceProvider);
    final net = ref.read(networkInfoProvider);
    final remote = ref.read(discoveryRemoteDatasourceProvider);

    final uid = _userId();
    final connected = await net.isConnected;

    try {
      if (connected) {
        final list = await remote.getDiscovery();
        await hive.saveDiscoveryCache(uid, list);

        _cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        final cached = await hive.getDiscoveryCache(uid);
        _cards = cached.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {
      final cached = await hive.getDiscoveryCache(uid);
      _cards = cached.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (mounted) setState(() => _loading = false);
  }

  int _ageFromDob(dynamic dob) {
    try {
      final dt = DateTime.parse(dob.toString());
      final now = DateTime.now();
      int age = now.year - dt.year;
      final hasHadBirthday = (now.month > dt.month) || (now.month == dt.month && now.day >= dt.day);
      if (!hasHadBirthday) age -= 1;
      return math.max(0, age);
    } catch (_) {
      return 0;
    }
  }

  Future<void> _sendSwipe(String targetUserId, String action) async {
    final net = ref.read(networkInfoProvider);
    final connected = await net.isConnected;

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offline: swipe will be added later (Day 2.5 sync)")),
      );
      return;
    }

    final swipeApi = ref.read(swipeRemoteDatasourceProvider);
    final res = await swipeApi.swipe(targetUserId: targetUserId, action: action);

    final matched = res["matched"] == true;
    if (matched) {
      final matchId = res["matchId"]?.toString() ?? "";
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("It’s a match!"),
          content: Text("matchId: $matchId"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  void _popTopCard() {
    if (_cards.isNotEmpty) {
      setState(() {
        _cards.removeAt(0);
        _dragOffset = Offset.zero;
      });
    }
  }

  Future<void> _finishSwipe(Size size) async {
    if (_cards.isEmpty) return;

    final dx = _dragOffset.dx;
    final threshold = size.width * 0.20;
    final top = _cards.first;
    final targetId = top["_id"]?.toString() ?? "";

    if (targetId.isEmpty) {
      setState(() => _dragOffset = Offset.zero);
      return;
    }

    if (dx > threshold) {
      await _sendSwipe(targetId, "like");
      _popTopCard();
      return;
    }
    if (dx < -threshold) {
      await _sendSwipe(targetId, "pass");
      _popTopCard();
      return;
    }

    setState(() => _dragOffset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxWidth = c.maxWidth >= 900 ? 620.0 : (c.maxWidth >= 600 ? 540.0 : double.infinity);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Discover"),
                actions: [
                  IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
                ],
              ),
              body: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _cards.isEmpty
                      ? const Center(child: Text("No more people. Create more users in DB."))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Expanded(
                                child: Draggable(
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: _DiscoveryCard(
                                      user: _cards.first,
                                      dragOffset: _dragOffset,
                                      showShadow: true,
                                      ageFromDob: _ageFromDob,
                                    ),
                                  ),
                                  childWhenDragging: const SizedBox.shrink(),
                                  onDragUpdate: (d) => setState(() => _dragOffset += d.delta),
                                  onDragEnd: (_) => _finishSwipe(Size(c.maxWidth, c.maxHeight)),
                                  child: _DiscoveryCard(
                                    user: _cards.first,
                                    dragOffset: _dragOffset,
                                    showShadow: false,
                                    ageFromDob: _ageFromDob,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _CircleButton(
                                    icon: Icons.close,
                                    size: 66,
                                    onTap: () async {
                                      final id = _cards.first["_id"]?.toString() ?? "";
                                      if (id.isNotEmpty) await _sendSwipe(id, "pass");
                                      _popTopCard();
                                    },
                                  ),
                                  _CircleButton(
                                    icon: Icons.favorite,
                                    size: 66,
                                    onTap: () async {
                                      final id = _cards.first["_id"]?.toString() ?? "";
                                      if (id.isNotEmpty) await _sendSwipe(id, "like");
                                      _popTopCard();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Offset dragOffset;
  final bool showShadow;
  final int Function(dynamic dob) ageFromDob;

  const _DiscoveryCard({
    required this.user,
    required this.dragOffset,
    required this.showShadow,
    required this.ageFromDob,
  });

  @override
  Widget build(BuildContext context) {
    final rotation = dragOffset.dx * 0.0006;
    final likeOpacity = (dragOffset.dx / 120).clamp(0.0, 1.0);
    final passOpacity = (-dragOffset.dx / 120).clamp(0.0, 1.0);

    final photos = (user["photos"] is List) ? List<String>.from(user["photos"]) : <String>[];
    final imageUrl = photos.isNotEmpty ? photos.first : null;

    final name = (user["fullName"]?.toString().trim().isNotEmpty == true)
        ? user["fullName"].toString()
        : (user["username"]?.toString() ?? "User");

    final age = ageFromDob(user["dob"]);

    return Transform.translate(
      offset: dragOffset,
      child: Transform.rotate(
        angle: rotation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: showShadow
                  ? [BoxShadow(blurRadius: 18, spreadRadius: 2, offset: const Offset(0, 10), color: Colors.black.withOpacity(0.18))]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl == null
                      ? Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.photo, size: 56)),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.broken_image_outlined, size: 56)),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Opacity(opacity: likeOpacity, child: const _Badge(text: "LIKE")),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Opacity(opacity: passOpacity, child: const _Badge(text: "NOPE")),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$name${age > 0 ? "  $age" : ""}",
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.08),
          border: Border.all(color: Colors.black.withOpacity(0.10)),
        ),
        child: Icon(icon, size: size * 0.44),
      ),
    );
  }
}