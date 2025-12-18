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
      // Menggunakan AppBar Custom Baru
      appBar: _buildCustomAppBar(context),

      // Container Body dengan Gradient
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

                  // Tandai pesan sebagai DELIVERED (hanya pesan masuk)
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

  /// =====================================================
  /// BAR ATAS
  /// =====================================================
  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    // Definisi warna sesuai request
    const Color mustardColor = Color(0xFFFFC107); // Oranye/Mustard
    const Color indigoColor = Color(0xFF4A5596); // Biru Indigo

    // Cek apakah image berupa URL atau Asset lokal
    final ImageProvider imageProvider = widget.profileImage.startsWith('http')
        ? NetworkImage(widget.profileImage)
        : AssetImage(widget.profileImage) as ImageProvider;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2, // Sedikit shadow
      shadowColor: Colors.black.withOpacity(0.2),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: mustardColor, // Icon Back Oranye
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0, // Mengurangi jarak antara panah dan foto
      title: Row(
        children: [
          // Foto Profil Lingkaran
          CircleAvatar(
            radius: 20,
            backgroundImage: imageProvider,
          ),
          const SizedBox(width: 12),

          // Info User (Nama & Status)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "Online", // Status Hardcoded sementara
                  style: TextStyle(
                    color: mustardColor, // Teks status Oranye
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Tombol 1: Telepon
        _buildCircleActionButton(
          icon: Icons.phone,
          color: indigoColor,
          onTap: () {
            // Aksi telepon
          },
        ),
        const SizedBox(width: 8),

        // Tombol 2: Lokasi
        _buildCircleActionButton(
          icon: Icons.location_on, // atau Icons.place
          color: indigoColor,
          onTap: () {
            // Aksi lokasi
          },
        ),
        const SizedBox(width: 16), // Padding kanan
      ],
    );
  }

  // Helper untuk tombol aksi bulat
  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
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

  /// =====================================================
  /// INPUT BAR
  /// =====================================================
  Widget _buildInputBar() {
    const Color creamColor = Color(0xFFFFF7E6);
    const Color indigoColor = Color(0xFF4A5596);
    const Color yellowColor = Color(0xFFFFC638);
    const Color whiteColor = Colors.white;

    return Container(
      color: creamColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              decoration: BoxDecoration(
                color: indigoColor,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    color: whiteColor,
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: whiteColor),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Tulis Pesan...",
                        hintStyle: TextStyle(
                          color: whiteColor.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: whiteColor,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: whiteColor,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_isTyping) {
                _sendMessage();
              } else {
                // Aksi rekam
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: yellowColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: whiteColor,
                size: 26,
              ),
            ),
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

  Widget _buildStatusIcon(Map<String, dynamic> msg, bool isMe) {
    if (!isMe) return const SizedBox.shrink();

    final isRead = msg['is_read'] == true;
    final deliveredAt = msg['delivered_at'];

    if (isRead) {
      return const Icon(Icons.done_all, size: 16, color: Colors.white);
    }

    if (deliveredAt != null) {
      return const Icon(Icons.done_all, size: 16, color: Colors.white70);
    }

    return const Icon(Icons.done, size: 16, color: Colors.white70);
  }
}
