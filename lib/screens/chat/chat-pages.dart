import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'chat-sadamp.dart';
import 'package:sahabat_rs/services/chat_service.dart';

class ChatPages extends StatefulWidget {
  const ChatPages({super.key});

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends State<ChatPages> {
  final supabase = Supabase.instance.client;
  final String _myUserId = Supabase.instance.client.auth.currentUser!.id;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _searchResults = [];

  /// =========================
  /// CACHE NAMA USER
  /// =========================
  final Map<String, String> _userNameCache = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// =========================
  /// AMBIL NAMA USER
  /// =========================
  Future<String> _getUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }

    final res = await supabase
        .from('pengguna')
        .select('name')
        .eq('id_pengguna', userId)
        .single();

    final name = res['name'] ?? 'Pengguna';
    _userNameCache[userId] = name;
    return name;
  }

  /// =========================
  /// SEARCH USER
  /// =========================
  void _onSearchChanged(String keyword) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (keyword.trim().isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      final res = await supabase
          .from('pengguna')
          .select('id_pengguna, name, email')
          .or('name.ilike.%$keyword%,email.ilike.%$keyword%')
          .neq('id_pengguna', _myUserId)
          .limit(20);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(res);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : _buildChatList(),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// HASIL SEARCH USER
  /// =========================
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];

        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/icons/ic_user.png'),
          ),
          title: Text(user['name'] ?? 'Pengguna'),
          subtitle: Text(user['email'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatSadamp(
                  userName: user['name'] ?? 'Pengguna',
                  profileImage: 'assets/icons/ic_user.png',
                  partnerId: user['id_pengguna'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// =========================
  /// CHAT LIST + UNREAD BADGE
  /// =========================
  Widget _buildChatList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatService.streamMessagesForUser(_myUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        final Map<String, Map<String, dynamic>> lastMessage = {};
        final Map<String, int> unreadCount = {};

        for (var msg in messages) {
          final partnerId = msg['sender_id'] == _myUserId
              ? msg['receiver_id']
              : msg['sender_id'];

          // simpan pesan terakhir
          lastMessage.putIfAbsent(partnerId, () => msg);

          // hitung unread
          if (msg['receiver_id'] == _myUserId && msg['is_read'] == false) {
            unreadCount[partnerId] = (unreadCount[partnerId] ?? 0) + 1;
          }
        }

        return ListView(
          children: lastMessage.entries.map((entry) {
            final partnerId = entry.key;
            final msg = entry.value;
            final unread = unreadCount[partnerId] ?? 0;

            final time = DateFormat('HH:mm')
                .format(DateTime.parse(msg['created_at']).toLocal());

            return ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/icons/ic_user.png'),
              ),
              title: FutureBuilder<String>(
                future: _getUserName(partnerId),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Pengguna',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
              subtitle: Text(
                msg['message'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(time, style: const TextStyle(fontSize: 12)),
                  if (unread > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatSadamp(
                      userName: _userNameCache[partnerId] ?? 'Pengguna',
                      profileImage: 'assets/icons/ic_user.png',
                      partnerId: partnerId,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Chat',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama atau email',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Cari pengguna untuk memulai chat',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
