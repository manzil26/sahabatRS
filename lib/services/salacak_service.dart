// lib/services/salacak_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sahabat_rs/models/keluarga.dart';
import 'package:sahabat_rs/models/lacak_pendampingan.dart';

/// Service khusus fitur SaLacak:
/// - Kelola orang terdekat (tabel `keluarga`)
/// - Ambil timeline pendampingan (tabel `lacak`)
class SaLacakService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Ambil ID user yang sedang login (UUID dari auth.users)
  static String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User belum login");
    }
    return user.id;
  }

  /// Ambil daftar orang terdekat untuk user yang sedang login
  static Future<List<Keluarga>> getKeluargaSaya() async {
    final data = await _client
        .from('keluarga')
        .select()
        .eq('id_pengguna', _currentUserId)
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((row) => Keluarga.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Tambah orang terdekat baru (nama + no HP)
  static Future<void> tambahKeluarga({
    required String nama,
    required String nomorTelepon,
    String? hubungan,
  }) async {
    await _client.from('keluarga').insert({
      'id_pengguna': _currentUserId,
      'nama_lengkap': nama,
      'nomor_telepon': nomorTelepon,
      'hubungan': hubungan,
    });
  }

  /// Ambil timeline pendampingan berdasarkan id_riwayatpesanan
  static Future<List<LacakPendampingan>> getPelacakan(
    int idRiwayatPesanan,
  ) async {
    final data = await _client
        .from('lacak')
        .select()
        .eq('id_riwayatpesanan', idRiwayatPesanan)
        .order('tanggal', ascending: true)
        .order('jam', ascending: true);

    return (data as List<dynamic>)
        .map((row) => LacakPendampingan.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
