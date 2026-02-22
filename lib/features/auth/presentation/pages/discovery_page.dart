// lib/features/discovery/presentation/discovery_page.dart
import 'dart:math' as math;

import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/discovery_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/chat_pages.dart';
import 'package:blink_flutter/features/auth/presentation/providers/matches_refresh_trigger_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  final GlobalKey<_DiscoveryCardState> _topCardKey =
      GlobalKey<_DiscoveryCardState>();

  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  Offset _dragOffset = Offset.zero;

  String _userId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "guest";

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
        _cards = cached
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
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
      final hasHadBirthday =
          (now.month > dt.month) ||
          (now.month == dt.month && now.day >= dt.day);
      if (!hasHadBirthday) age -= 1;
      return math.max(0, age);
    } catch (_) {
      return 0;
    }
  }

  List<String> _extractPhotos(dynamic photosField) {
    if (photosField is! List) return <String>[];
    return photosField
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _displayName(Map<String, dynamic> user) {
    final fullName = user["fullName"]?.toString().trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final username = user["username"]?.toString().trim();
    if (username != null && username.isNotEmpty) return username;
    return "User";
  }

  Future<Map<String, dynamic>?> _tryLoadMyProfile() async {
    final hive = ref.read(hiveServiceProvider);
    final uid = _userId();

    final ProfileHiveModel? p = await hive.getProfileByUserId(uid);
    if (p == null) return null;

    return <String, dynamic>{
      "userId": p.userId,
      "fullName": p.fullName,
      "dob": p.dob,
      "gender": p.gender,
      "lookingFor": p.lookingFor,
      "photos": (p.photos ?? <String>[]),
    };
  }

  Future<void> _showMatchModal({
    required String matchId,
    required Map<String, dynamic> otherUser,
  }) async {
    final myProfile = await _tryLoadMyProfile();

    final myName = myProfile == null ? "You" : _displayName(myProfile);
    final otherName = _displayName(otherUser);

    final myPhotos = myProfile == null
        ? <String>[]
        : _extractPhotos(myProfile["photos"]);
    final otherPhotos = _extractPhotos(otherUser["photos"]);

    final myAvatar = myPhotos.isNotEmpty ? myPhotos.first : null;
    final otherAvatar = otherPhotos.isNotEmpty ? otherPhotos.first : null;

    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "match",
      barrierColor: Colors.black.withOpacity(0.70),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _MatchModal(
                  myName: myName,
                  otherName: otherName,
                  myAvatarUrl: myAvatar,
                  otherAvatarUrl: otherAvatar,
                  onKeepSwiping: () => Navigator.pop(context),
                  onSendMessage: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          matchId: matchId,
                          title: otherName,
                          avatarUrl: otherAvatar,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
    if (!mounted) return;
    ref.read(matchesRefreshTriggerProvider.notifier).state++;
  }

  Future<void> _sendSwipe(
    String targetUserId,
    String action,
    Map<String, dynamic> otherUserCard,
  ) async {
    final net = ref.read(networkInfoProvider);
    final connected = await net.isConnected;

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Offline: swipe will be added later (Day 2.5 sync)"),
        ),
      );
      return;
    }

    final swipeApi = ref.read(swipeRemoteDatasourceProvider);
    final res = await swipeApi.swipe(
      targetUserId: targetUserId,
      action: action,
    );

    final matched = res["matched"] == true;
    if (matched) {
      final matchId = res["matchId"]?.toString() ?? "";
      if (matchId.isNotEmpty) {
        await _showMatchModal(matchId: matchId, otherUser: otherUserCard);
      }
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
      await _sendSwipe(targetId, "like", top);
      _popTopCard();
      return;
    }
    if (dx < -threshold) {
      await _sendSwipe(targetId, "pass", top);
      _popTopCard();
      return;
    }

    setState(() => _dragOffset = Offset.zero);
  }

  void _handleTapToChangePhoto(BuildContext context, TapUpDetails d) {
    final box = context.findRenderObject();
    if (box is! RenderBox) return;

    final local = box.globalToLocal(d.globalPosition);
    final width = box.size.width;
    if (width <= 0) return;

    if (local.dx < width / 2) {
      _topCardKey.currentState?.prevPhoto();
    } else {
      _topCardKey.currentState?.nextPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxWidth = c.maxWidth >= 900
            ? 620.0
            : (c.maxWidth >= 600 ? 540.0 : double.infinity);

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
                  ? const Center(
                      child: Text("No more people. Create more users in DB."),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (cardCtx) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (d) =>
                                    _handleTapToChangePhoto(cardCtx, d),
                                onPanUpdate: (d) =>
                                    setState(() => _dragOffset += d.delta),
                                onPanEnd: (_) =>
                                    _finishSwipe(Size(c.maxWidth, c.maxHeight)),
                                child: _DiscoveryCard(
                                  key: _topCardKey,
                                  user: _cards.first,
                                  dragOffset: _dragOffset,
                                  showShadow: true,
                                  ageFromDob: _ageFromDob,
                                ),
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
                                  final top = _cards.first;
                                  final id = top["_id"]?.toString() ?? "";
                                  if (id.isNotEmpty)
                                    await _sendSwipe(id, "pass", top);
                                  _popTopCard();
                                },
                              ),
                              _CircleButton(
                                icon: Icons.favorite,
                                size: 66,
                                onTap: () async {
                                  final top = _cards.first;
                                  final id = top["_id"]?.toString() ?? "";
                                  if (id.isNotEmpty)
                                    await _sendSwipe(id, "like", top);
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

class _DiscoveryCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final Offset dragOffset;
  final bool showShadow;
  final int Function(dynamic dob) ageFromDob;

  const _DiscoveryCard({
    super.key,
    required this.user,
    required this.dragOffset,
    required this.showShadow,
    required this.ageFromDob,
  });

  @override
  State<_DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<_DiscoveryCard> {
  static const int _maxSlots = 6;

  late final PageController _pageController;
  int _photoIndex = 0;
  int _photoCount = _maxSlots;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPhoto() => _goTo(_photoIndex + 1);
  void prevPhoto() => _goTo(_photoIndex - 1);

  void _safeJumpToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) _pageController.jumpToPage(index);
    });
  }

  void _safeAnimateToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goTo(int next) {
    final count = _photoCount;
    if (count <= 1) return;

    final clamped = next.clamp(0, count - 1);
    if (clamped == _photoIndex) return;

    setState(() => _photoIndex = clamped);
    _safeAnimateToPage(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.user["_id"]?.toString();
    if (currentUserId != null && currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      _photoIndex = 0;
      _safeJumpToPage(0);
    }

    final rotation = widget.dragOffset.dx * 0.0006;
    final likeOpacity = (widget.dragOffset.dx / 120).clamp(0.0, 1.0);
    final passOpacity = (-widget.dragOffset.dx / 120).clamp(0.0, 1.0);

    final photos = (widget.user["photos"] is List)
        ? List<String>.from(widget.user["photos"])
        : <String>[];
    final cleanedPhotos = photos
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final slots = List<String?>.generate(
      _maxSlots,
      (i) => i < cleanedPhotos.length ? cleanedPhotos[i] : null,
    );

    final photoCount = slots.length; // always 6
    _photoCount = photoCount;

    if (_photoIndex >= photoCount) {
      _photoIndex = 0;
      _safeJumpToPage(0);
    }

    final name = (widget.user["fullName"]?.toString().trim().isNotEmpty == true)
        ? widget.user["fullName"].toString()
        : (widget.user["username"]?.toString() ?? "User");

    final age = widget.ageFromDob(widget.user["dob"]);

    return Transform.translate(
      offset: widget.dragOffset,
      child: Transform.rotate(
        angle: rotation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: widget.showShadow
                  ? [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.18),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: photoCount,
                        itemBuilder: (_, i) {
                          final url = slots[i];
                          if (url == null) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_outlined, size: 56),
                                    SizedBox(height: 8),
                                    Text(
                                      "No photo",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 56,
                                ),
                              ),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 12,
                        child: _PhotoBars(
                          count: photoCount,
                          index: _photoIndex,
                        ),
                      ),
                    ],
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
                  child: Opacity(
                    opacity: likeOpacity,
                    child: const _Badge(text: "LIKE"),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Opacity(
                    opacity: passOpacity,
                    child: const _Badge(text: "NOPE"),
                  ),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: Colors.lightBlueAccent,
                        size: 22,
                      ),
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

class _MatchModal extends StatelessWidget {
  final String myName;
  final String otherName;
  final String? myAvatarUrl;
  final String? otherAvatarUrl;
  final VoidCallback onKeepSwiping;
  final VoidCallback onSendMessage;

  const _MatchModal({
    required this.myName,
    required this.otherName,
    required this.myAvatarUrl,
    required this.otherAvatarUrl,
    required this.onKeepSwiping,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          const Text(
            "It’s a match!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MatchAvatar(url: myAvatarUrl, label: myName),
              const SizedBox(width: 16),
              _MatchAvatar(url: otherAvatarUrl, label: otherName),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSendMessage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Send Message"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onKeepSwiping,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Keep Swiping"),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  final String? url;
  final String label;

  const _MatchAvatar({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    final hasUrl = u != null && u.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAEAEA),
            image: hasUrl
                ? DecorationImage(image: NetworkImage(u!), fit: BoxFit.cover)
                : null,
          ),
          child: hasUrl
              ? null
              : const Icon(Icons.person, size: 42, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 120,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _PhotoBars extends StatelessWidget {
  final int count;
  final int index;

  const _PhotoBars({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

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
