// lib/features/chat/presentation/chat_page.dart
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
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
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _messages = <_Msg>[
    const _Msg(isMe: false, text: "Hey, what's up with dog pics?"),
    const _Msg(isMe: true, text: "cuz em a dog 🐶"),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(_Msg(isMe: true, text: text)));
    _controller.clear();

    // Day 3: POST /matches/:matchId/messages
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.avatarUrl == null ? null : NetworkImage(widget.avatarUrl!),
              child: widget.avatarUrl == null ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            "You matched with ${widget.title}.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: m.isMe ? Colors.blue : Colors.grey.shade200,
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(color: m.isMe ? Colors.white : Colors.black87),
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
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
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
                    onPressed: _send,
                    child: const Text("SEND"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final bool isMe;
  final String text;
  const _Msg({required this.isMe, required this.text});
}