import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi scroll otomatis ke bawah
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Tunggu render frame selesai baru scroll
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
      await Supabase.instance.client.from('chat').insert({
        'sender_id': _myUserId,
        'receiver_id': widget.partnerId,
        'message': text,
        'is_read': false,
      });

      // Panggil fungsi scroll ke bawah setelah kirim
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengirim: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6A230), // Atas: Oranye
              Color(0xFFFFFFFF), // Bawah: Putih
            ],
          ),
        ),
        child: Column(
          children: [
            // --- DAFTAR PESAN ---
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('chat')
                    .stream(primaryKey: ['id'])
                    .order('created_at',
                        ascending: true) // Urutan: Lama -> Baru
                    .map((data) => data.where((msg) {
                          return (msg['sender_id'] == _myUserId &&
                                  msg['receiver_id'] == widget.partnerId) ||
                              (msg['sender_id'] == widget.partnerId &&
                                  msg['receiver_id'] == _myUserId);
                        }).toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;

                  // Auto scroll ke bawah saat pertama kali load data atau ada pesan baru
                  if (messages.isNotEmpty) {
                    _scrollToBottom();
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        "Mulai percakapan dengan ${widget.userName}",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: false, // UBAH: False agar mulai dari atas ke bawah
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == _myUserId;
                      final time = DateFormat('HH:mm')
                          .format(DateTime.parse(msg['created_at']).toLocal());
                      final isRead = msg['is_read'] == true;

                      return _buildMessageBubble(
                          msg['message'], time, isMe, isRead);
                    },
                  );
                },
              ),
            ),

            // --- INPUT BAR ---
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
      toolbarHeight: 70,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(widget.profileImage),
            backgroundColor: Colors.grey[200],
            onBackgroundImageError: (_, __) {},
            child: widget.profileImage.contains('assets')
                ? null
                : const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                "Online",
                style: TextStyle(
                    color: Color(0xFFF6A230),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.black54, size: 26),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.black54, size: 26),
          onPressed: () {},
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildMessageBubble(
      String message, String time, bool isMe, bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end, // Avatar sejajar bawah bubble
        children: [
          // 1. Avatar Pendamping (Kiri) - Hanya jika BUKAN saya
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.profileImage),
              backgroundColor: Colors.grey[200],
              onBackgroundImageError: (_, __) {},
              child: widget.profileImage.contains('assets')
                  ? null
                  : const Icon(Icons.person, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          // 2. Bubble Chat
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFF6A230) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : Colors.black87,
                        height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: isRead ? Colors.blue[100] : Colors.white38,
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Avatar User (Kanan) - Hanya jika SAYA
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              // Gunakan icon user default
              backgroundImage: AssetImage('assets/icons/ic_user.png'),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF5966B1),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Tulis Pesan...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon:
                      Icon(Icons.camera_alt, color: Colors.white70, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping
                ? _sendMessage
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Fitur Voice Note belum tersedia")));
                  },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF6A230),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                color: _isTyping ? const Color(0xFF5966B1) : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
