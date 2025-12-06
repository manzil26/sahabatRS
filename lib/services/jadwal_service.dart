// lib/services/jadwal_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jadwal_obat.dart';
import '../models/jadwal_checkup_detail.dart';

// Dapatkan instance client Supabase
final supabase = Supabase.instance.client;

class JadwalService {
  // Asumsi: ID pengguna yang sedang login
  static const int _currentUserId = 1;

  // --- 1. Ambil Jadwal Check-Up berikutnya dari tabel 'checkup' ---
  // Tipe kembalian: Future<JadwalCheckUpDetail?>
  static Future<JadwalCheckUpDetail?> getNextJadwalCheckUpDetail() async {
    try {
      // Query ke tabel 'checkup'
      final response = await supabase
          .from('checkup') // Menggunakan tabel 'checkup' yang baru
          .select(
            '*',
          ) // Karena tabel ini sudah mencakup semua data yang dibutuhkan
          .eq('id_pengguna', _currentUserId)
          // Filter hanya yang akan datang (atau hari ini)
          .gte('tanggal', DateTime.now().toIso8601String().split('T')[0])
          .order('tanggal', ascending: true)
          .limit(1)
          .maybeSingle(); // Menggunakan maybeSingle untuk menangani nol hasil

      if (response == null) {
        return null;
      }

      // Mapping data langsung ke model
      return JadwalCheckUpDetail.fromMap({
        'id_checkup': response['id_checkup'],
        'tanggal': response['tanggal'],
        'lokasi': response['lokasi'],
        'kegiatan': response['kegiatan'],
        'kondisi_tambahan': response['kondisi_tambahan'],
        'waktu_notifikasi': response['waktu_notifikasi'],
      });
    } catch (e) {
      print('Error fetching Next Jadwal Check-Up Detail: $e');
      return null;
    }
  }

  // --- 2. Ambil SEMUA Jadwal Check-Up untuk Kalender (Hanya tanggal) ---
  static Future<List<DateTime>> getAllJadwalDates() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('checkup') // Menggunakan tabel 'checkup'
          .select('tanggal')
          .eq('id_pengguna', _currentUserId)
          .order('tanggal', ascending: true);

      return response.map((data) => DateTime.parse(data['tanggal'])).toList();
    } catch (e) {
      print('Error fetching All Jadwal Dates: $e');
      return [];
    }
  }

  // --- 3. Ambil Tinjauan Obat Harian (Tidak Berubah) ---
  static Future<List<JadwalObat>> getTinjauanObatHarian() async {
    try {
      // Query ke tabel jadwalobat
      final List<Map<String, dynamic>> response = await supabase
          .from('jadwalobat')
          .select('*')
          .eq('id_pengguna', _currentUserId)
          .order('jam_minum', ascending: true);

      // Mapping data ke model yang sudah diperbaiki
      return response.map((data) => JadwalObat.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching Tinjauan Obat Harian: $e');
      return [];
    }
  }
}
