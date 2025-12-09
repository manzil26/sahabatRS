import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'chat-sadamp.dart';

class ChatPages extends StatefulWidget {
  const ChatPages({super.key});

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends State<ChatPages> {
  final String _myUserId = Supabase.instance.client.auth.currentUser!.id;

  // DATA DUMMY (Ghost Users) dengan Foto Profil
  final Map<String, Map<String, String>> _dummyProfiles = {
    '11111111-1111-1111-1111-111111111111': {
      'name': 'Esa Anugrah',
      'role': 'Driver Ambulance',
      'image': 'assets/images/driver.png', // Pastikan aset ini ada
      'is_verified': 'true'
    },
    '22222222-2222-2222-2222-222222222222': {
      'name': 'Siti Aminah',
      'role': 'Perawat Pendamping',
      'image': 'assets/images/nurse.png', // Pastikan aset ini ada
      'is_verified': 'false'
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER & SEARCH
            _buildCustomHeader(),

            // LIST CHAT
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client.from('chat').stream(
                    primaryKey: ['id']).order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allMessages = snapshot.data ?? [];

                  // Filter pesan milik saya
                  final myMessages = allMessages.where((msg) {
                    return msg['sender_id'] == _myUserId ||
                        msg['receiver_id'] == _myUserId;
                  }).toList();

                  if (myMessages.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Grouping pesan terakhir per user
                  final Map<String, Map<String, dynamic>> lastMessagePerUser =
                      {};

                  for (var msg in myMessages) {
                    final isMeSender = msg['sender_id'] == _myUserId;
                    final partnerId =
                        isMeSender ? msg['receiver_id'] : msg['sender_id'];

                    if (!lastMessagePerUser.containsKey(partnerId)) {
                      lastMessagePerUser[partnerId] = {
                        'partner_id': partnerId,
                        'last_message': msg['message'] ?? '',
                        'created_at': msg['created_at'],
                        'unread_count': 0,
                      };
                    }

                    if (msg['receiver_id'] == _myUserId &&
                        (msg['is_read'] == false || msg['is_read'] == null)) {
                      lastMessagePerUser[partnerId]!['unread_count'] += 1;
                    }
                  }

                  final conversationList = lastMessagePerUser.values.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: conversationList.length,
                    itemBuilder: (context, index) {
                      return _buildChatItem(context, conversationList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 20, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.mail_outline_rounded,
                        size: 20, color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBCF41),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    final date = DateTime.parse(chat['created_at']);
    final timeStr = DateFormat('HH:mm').format(date.toLocal());
    final unreadCount = chat['unread_count'] as int;
    final partnerId = chat['partner_id'] as String;

    String displayName = 'Pengguna';
    String displayImage = 'assets/icons/ic_user.png'; // Default
    bool isVerified = false;

    // Logika Avatar: Cek apakah user dummy atau user biasa
    if (_dummyProfiles.containsKey(partnerId)) {
      final profile = _dummyProfiles[partnerId]!;
      displayName = profile['name']!;
      displayImage = profile['image']!;
      isVerified = profile['is_verified'] == 'true';
    }

    return InkWell(
      onTap: () async {
        await Supabase.instance.client
            .from('chat')
            .update({'is_read': true})
            .eq('sender_id', partnerId)
            .eq('receiver_id', _myUserId);

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatSadamp(
                userName: displayName,
                profileImage: displayImage, // Kirim foto profil ke detail chat
                partnerId: partnerId,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // FOTO PROFIL (AVATAR)
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(displayImage),
              onBackgroundImageError: (_, __) {},
              child: displayImage.contains('assets')
                  ? null
                  : const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 16),

            // NAMA & PREVIEW
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Jika bukan dummy user, coba ambil nama dari database
                      if (!_dummyProfiles.containsKey(partnerId))
                        FutureBuilder(
                          future: Supabase.instance.client
                              .from('profiles')
                              .select('full_name')
                              .eq('id', partnerId)
                              .maybeSingle(),
                          builder: (context, snap) {
                            final name = (snap.data != null &&
                                    snap.data!['full_name'] != null)
                                ? snap.data!['full_name']
                                : 'Pengguna';
                            // Hack: update lokal var agar navigasi berikutnya benar
                            displayName = name;
                            return Text(name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold));
                          },
                        )
                      else
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),

                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 16, color: Colors.blue),
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chat['last_message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A959E),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // META DATA
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A959E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (unreadCount > 0)
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6A230),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada pesan", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
