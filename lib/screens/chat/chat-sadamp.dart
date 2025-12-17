import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sahabat_rs/services/chat_service.dart';

class ChatSadamp extends StatefulWidget {
  final String userName;
  final String profileImage;
  final String partnerId;

  const ChatSadamp({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.partnerId,
  });

  @override
  State<ChatSadamp> createState() => _ChatSadampState();
}

class _ChatSadampState extends State<ChatSadamp> {
  final TextEditingController _messageController = TextEditingController();
  final String _myUserId = Supabase.instance.client.auth.currentUser!.id;
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  // Pagination
  bool _isLoadingEarlier = false;
  List<Map<String, dynamic>> _earlierMessages = [];
  DateTime? _earliestMessageAt;

  @override
  void initState() {
    super.initState();

    /// Tandai pesan sebagai dibaca saat chat dibuka
    ChatService.markMessagesAsRead(
      myId: _myUserId,
      partnerId: widget.partnerId,
    );

    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isTyping = false);

    try {
      await ChatService.sendMessage(
        senderId: _myUserId,
        receiverId: widget.partnerId,
        message: text,
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 0 && !_isLoadingEarlier) {
      _loadEarlierMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context),
      // 1. REVISI: Menambahkan Container dengan Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange, // Atas Oranye
              Colors.white, // Bawah Putih
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: ChatService.streamConversationBetween(
                  _myUserId,
                  widget.partnerId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final streamMessages = snapshot.data!;

                  /// ✅ Tandai pesan sebagai DELIVERED (hanya pesan masuk)
                  if (streamMessages.isNotEmpty) {
                    ChatService.markMessagesAsDelivered(
                      myId: _myUserId,
                      partnerId: widget.partnerId,
                    );
                  }

                  final Map<int, Map<String, dynamic>> merged = {};

                  for (var m in _earlierMessages) {
                    merged[m['id'] as int] = m;
                  }

                  for (var m in streamMessages) {
                    final id = m['id'] is int
                        ? m['id'] as int
                        : int.parse(m['id'].toString());
                    merged[id] = m;
                  }

                  final messages = merged.values.toList()
                    ..sort((a, b) => DateTime.parse(a['created_at'])
                        .compareTo(DateTime.parse(b['created_at'])));

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (messages.isNotEmpty) {
                      _scrollToBottom();
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == _myUserId;
                      final time = DateFormat('HH:mm').format(
                        DateTime.parse(msg['created_at']).toLocal(),
                      );

                      return _buildMessageBubble(msg, time, isMe);
                    },
                  );
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  AppBar _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.userName, style: const TextStyle(color: Colors.black)),
    );
  }

  Future<void> _loadEarlierMessages() async {
    if (_isLoadingEarlier) return;
    setState(() => _isLoadingEarlier = true);

    try {
      final older = await ChatService.fetchMessagesBetween(
        _myUserId,
        widget.partnerId,
        limit: 50,
        before: _earliestMessageAt,
      );

      if (older.isNotEmpty) {
        setState(() {
          _earlierMessages = [...older, ..._earlierMessages];
          _earliestMessageAt =
              DateTime.parse(_earlierMessages.first['created_at']);
        });
      }
    } finally {
      setState(() => _isLoadingEarlier = false);
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF5966B1),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Tulis Pesan...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _isTyping ? _sendMessage : null,
          ),
        ],
      ),
    );
  }

  /// =====================================================
  /// BUBBLE + STATUS ICON
  /// =====================================================
  Widget _buildMessageBubble(Map<String, dynamic> msg, String time, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // 2. REVISI: Pengirim Biru, Penerima Putih
          color: isMe ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['message'],
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                _buildStatusIcon(msg, isMe),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// =====================================================
  /// ICON STATUS (✔ / ✔✔)
  /// =====================================================
  Widget _buildStatusIcon(Map<String, dynamic> msg, bool isMe) {
    if (!isMe) return const SizedBox.shrink();

    final isRead = msg['is_read'] == true;
    final deliveredAt = msg['delivered_at'];

    if (isRead) {
      // Ubah icon centang baca menjadi Putih Terang agar terlihat di background Biru
      // (Sebelumnya Biru, tapi Biru di atas Biru tidak akan terlihat)
      return const Icon(Icons.done_all, size: 16, color: Colors.white);
    }

    if (deliveredAt != null) {
      return const Icon(Icons.done_all, size: 16, color: Colors.white70);
    }

    return const Icon(Icons.done, size: 16, color: Colors.white70);
  }
}
