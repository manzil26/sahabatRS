import 'package:flutter/material.dart';
import 'chat-sadamp.dart'; // Import halaman detail chat

class ChatPages extends StatelessWidget {
  const ChatPages({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk daftar chat
    final List<Map<String, dynamic>> chatList = [
      {
        "name": "Esa Anugrah",
        "role": "Driver Ambulance",
        "message": "Saya sudah sampai di depan pak...",
        "time": "10:30",
        "unread": 2,
        "image": "assets/images/driver.png" 
      },
      {
        "name": "Siti Aminah",
        "role": "Perawat Pendamping",
        "message": "Baik bu, jangan lupa obatnya dim...",
        "time": "Kemarin",
        "unread": 0,
        "image": "assets/images/nurse.png"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          "Pesan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return _buildChatItem(context, chat);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        // Navigasi ke Ruang Chat (ChatPendamping)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPendamping(
              userName: chat['name'], // Mengirim nama ke ChatPendamping
              profileImage: chat['image'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(chat['image']),
              onBackgroundImageError: (_, __) {}, 
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            
            // Nama & Pesan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat['unread'] > 0 ? Colors.black87 : Colors.grey,
                      fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Waktu & Badge Unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: chat['unread'] > 0 ? const Color(0xFFFFAA2B) : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFAA2B), // Warna Orange
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['unread'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}