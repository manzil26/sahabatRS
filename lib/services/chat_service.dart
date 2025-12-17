import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// =====================================================
  /// STREAM SEMUA PESAN MILIK USER (UNTUK CHAT LIST)
  /// =====================================================
  static Stream<List<Map<String, dynamic>>> streamMessagesForUser(
      String userId) {
    return _client
        .from('chat')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          final data = rows.cast<Map<String, dynamic>>();
          return data
              .where(
                (m) => m['sender_id'] == userId || m['receiver_id'] == userId,
              )
              .toList();
        });
  }

  /// =====================================================
  /// STREAM PESAN ANTARA 2 USER (REALTIME CHAT)
  /// =====================================================
  static Stream<List<Map<String, dynamic>>> streamConversationBetween(
      String myId, String partnerId) {
    return _client
        .from('chat')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((rows) {
          final data = rows.cast<Map<String, dynamic>>();
          return data.where((m) {
            return (m['sender_id'] == myId && m['receiver_id'] == partnerId) ||
                (m['sender_id'] == partnerId && m['receiver_id'] == myId);
          }).toList();
        });
  }

  /// =====================================================
  /// FETCH PESAN LAMA (PAGINATION / LOAD EARLIER)
  /// =====================================================
  static Future<List<Map<String, dynamic>>> fetchMessagesBetween(
    String myId,
    String partnerId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final res = await _client
        .from('chat')
        .select()
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$partnerId),'
          'and(sender_id.eq.$partnerId,receiver_id.eq.$myId)',
        )
        .order('created_at', ascending: false)
        .limit(200);

    var list = (res as List).cast<Map<String, dynamic>>();

    if (before != null) {
      list = list
          .where(
            (m) => DateTime.parse(m['created_at']).isBefore(before),
          )
          .toList();
    }

    if (list.length > limit) {
      list = list.sublist(0, limit);
    }

    return list.reversed.toList();
  }

  /// =====================================================
  /// KIRIM PESAN (INSERT ONLY — RLS SAFE)
  /// =====================================================
  static Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String type = 'text',
    String? attachmentUrl,
  }) async {
    await _client.from('chat').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'type': type,
      'attachment_url': attachmentUrl,
      'is_read': false,
      // dikirim = pesan berhasil masuk DB
      'delivered_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// =====================================================
  /// RECEIVER: TANDAI PESAN SUDAH DIBACA
  /// (HANYA UPDATE is_read & read_at)
  /// =====================================================
  static Future<void> markMessagesAsRead({
    required String myId,
    required String partnerId,
  }) async {
    await _client
        .from('chat')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('receiver_id', myId)
        .eq('sender_id', partnerId)
        .eq('is_read', false);
  }

  /// =====================================================
  /// RECEIVER: TANDAI PESAN SUDAH DITERIMA (DELIVERED)
  /// (HANYA UPDATE delivered_at JIKA NULL)
  /// =====================================================
  static Future<void> markMessagesAsDelivered({
    required String myId,
    required String partnerId,
  }) async {
    await _client
        .from('chat')
        .update({
          'delivered_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('receiver_id', myId)
        .eq('sender_id', partnerId)
        .isFilter('delivered_at', null);
  }

  /// =====================================================
  /// SENDER: UPDATE STATUS TERKIRIM (OPSIONAL / ADMIN LOGIC)
  /// (DIGUNAKAN JIKA BERBASIS chatId)
  /// =====================================================
  static Future<void> markAsDeliveredBySender({
    required int chatId,
    required String senderId,
  }) async {
    await _client
        .from('chat')
        .update({
          'delivered_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', chatId)
        .eq('sender_id', senderId);
  }
}
