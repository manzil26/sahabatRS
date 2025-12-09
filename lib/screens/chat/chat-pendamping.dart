import 'package:flutter/material.dart';

// Model Pesan Lokal
class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isRead = false,
  });
}

class ChatPendamping extends StatefulWidget {
  final String userName;
  final String? profileImage;
  final bool isOnline;

  const ChatPendamping({
    super.key,
    required this.userName,
    this.profileImage,
    this.isOnline = true,
  });

  @override
  State<ChatPendamping> createState() => _ChatPendampingState();
}

class _ChatPendampingState extends State<ChatPendamping> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessage> _messages = [
    ChatMessage(text: "Mohon ditunggu 🙏", isMe: false, time: "10.30"),
    ChatMessage(
        text: "Baik pak, terima kasih",
        isMe: true,
        time: "10.33",
        isRead: true),
  ];

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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        isMe: true,
        time: "10.35",
        isRead: false,
      ));
      _messageController.clear();
      _isTyping = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeAksen = Color(0xFFF6A230);
    const Color creamBackground = Color(0xFFFFF8E1);
    const Color blueInput = Color(0xFF5966B1);

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: widget.profileImage != null
                  ? AssetImage(widget.profileImage!)
                  : const AssetImage('assets/icons/ic_user.png'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                if (widget.isOnline)
                  const Text('Online',
                      style: TextStyle(
                          color: orangeAksen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        actions: [
          // Tombol Telepon & Lokasi (Khusus Pendamping)
          _buildActionButton(Icons.call),
          const SizedBox(width: 8),
          _buildActionButton(Icons.location_on),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(_messages[index]),
            ),
          ),
          _buildInputArea(blueInput, orangeAksen),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF5966B1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildInputArea(Color blueInput, Color orangeAksen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: blueInput,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 28),
                onPressed: () {}),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Tulis Pesan...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    suffixIcon: Icon(Icons.camera_alt, color: Colors.white70),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isTyping ? _sendMessage : () {},
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _isTyping ? Colors.blue : orangeAksen,
                    shape: BoxShape.circle),
                child: Icon(_isTyping ? Icons.send : Icons.mic,
                    color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    const Color bubbleUser = Color(0xFFF6A230);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isMe ? bubbleUser : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    message.isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                    message.isMe ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(message.text,
                    style: TextStyle(
                        fontSize: 15,
                        color: message.isMe ? Colors.black : Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message.time,
                        style: TextStyle(
                            fontSize: 10,
                            color:
                                message.isMe ? Colors.black54 : Colors.grey)),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue[800]
                              : Colors.black54),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
