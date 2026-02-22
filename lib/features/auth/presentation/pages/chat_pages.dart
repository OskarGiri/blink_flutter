import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/message_remote_datasource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String matchId;
  final String title;
  final String? avatarUrl;

  const ChatPage({
    super.key,
    required this.matchId,
    required this.title,
    this.avatarUrl,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _loading = true;
  String? _error;
  List<_Msg> _messages = [];
  bool _sending = false;

  ProviderSubscription<AsyncValue<Map<String, dynamic>>>? _socketSub;

  String _myUserId() =>
      ref.read(userSessionServiceProvider).getCurrentUserId() ?? "";

  @override
  void initState() {
    super.initState();

    // ✅ Listen once (Tinder-style), do NOT put ref.listen inside build()
    _socketSub = ref.listenManual<AsyncValue<Map<String, dynamic>>>(
      messageNewStreamProvider,
      (_, next) {
        next.whenData(_handleIncomingSocketMessage);
      },
    );

    Future.microtask(_loadMessages);
  }

  @override
  void dispose() {
    _socketSub?.close();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _handleIncomingSocketMessage(Map<String, dynamic> payload) {
    final matchId = (payload['matchId'] ?? '').toString();
    if (matchId != widget.matchId) return;

    final id = (payload['id'] ?? '').toString();
    final senderId = (payload['senderId'] ?? '').toString();
    final text = (payload['text'] ?? '').toString();
    final createdAt = (payload['createdAt'] ?? '').toString();
    if (id.isEmpty || text.isEmpty) return;

    if (_messages.any((m) => m.id == id)) return;

    final myId = _myUserId();
    final incoming = _Msg(
      id: id,
      isMe: myId.isNotEmpty && senderId == myId,
      text: text,
      createdAt: createdAt,
    );

    if (!mounted) return;
    setState(() => _messages = [..._messages, incoming]);
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = ref.read(messagesRemoteDatasourceProvider);
      final raw = await api.getMessages(matchId: widget.matchId, limit: 80);

      final myId = _myUserId();
      final parsed = raw.map((m) {
        final senderId = (m['senderId'] ?? '').toString();
        final text = (m['text'] ?? '').toString();
        final createdAt = (m['createdAt'] ?? '').toString();
        return _Msg(
          id: (m['id'] ?? '').toString(),
          isMe: myId.isNotEmpty && senderId == myId,
          text: text,
          createdAt: createdAt,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _messages = parsed;
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Failed to load messages: $e";
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    final optimistic = _Msg(
      id: "tmp_${DateTime.now().millisecondsSinceEpoch}",
      isMe: true,
      text: text,
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() => _messages = [..._messages, optimistic]);
    _scrollToBottom();

    try {
      final api = ref.read(messagesRemoteDatasourceProvider);
      await api.sendMessage(matchId: widget.matchId, text: text);

      // Keep this one-time refresh to replace tmp_* id with real id
      await _loadMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Send failed: $e");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    return Align(
                      alignment: m.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: m.isMe ? Colors.blue : Colors.grey.shade200,
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Type a message ...",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      TextButton(
                        onPressed: _sending ? null : _send,
                        child: Text(_sending ? "..." : "SEND"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.avatarUrl == null
                  ? null
                  : NetworkImage(widget.avatarUrl!),
              child: widget.avatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.title, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: body,
    );
  }
}

class _Msg {
  final String id;
  final bool isMe;
  final String text;
  final String createdAt;

  const _Msg({
    required this.id,
    required this.isMe,
    required this.text,
    required this.createdAt,
  });
}
