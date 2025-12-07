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
          .from('checkup')
          .select(
            'id_checkup, tanggal, lokasi, kegiatan, kondisi_tambahan, waktu_notifikasi',
          )
          .eq('id_pengguna', _currentUserId)
          // Filter hanya yang akan datang (atau hari ini)
          .gte('tanggal', DateTime.now().toIso8601String().split('T')[0])
          .order('tanggal', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Mapping data ke model menggunakan fromMap
      return JadwalCheckUpDetail.fromMap(response);
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

  // --- 3. Update Jadwal Obat ---
  static Future<bool> updateObat(JadwalObat obat) async {
    try {
      await supabase
          .from('jadwalobat')
          .update({
            'nama_obat': obat.namaObat,
            'jumlah_obat': obat.jumlahObat,
            'durasi_hari': obat.durasiHari,
            'jenis_waktu_makan': obat.jenisWaktuMakan,
            // Format TimeOfDay ke string "HH:MM:SS"
            'jam_minum':
                '${obat.jamMinum.hour.toString().padLeft(2, '0')}:${obat.jamMinum.minute.toString().padLeft(2, '0')}:00',
            'catatan': obat.catatan,
            'status': obat.statusSelesai,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_jadwalobat', obat.id)
          .select();

      return true;
    } catch (e) {
      print('Error updating Jadwal Obat: $e');
      return false;
    }
  }

  // --- 4. Hapus Jadwal Obat (Perbaikan Error PostgrestException) ---
  static Future<bool> deleteObat(int idObat) async {
    try {
      // PERBAIKAN: Melewatkan variabel idObat (integer) alih-alih string literal 'idObat'
      await supabase.from('jadwalobat').delete().eq('id_jadwalobat', idObat);
      return true;
    } catch (e) {
      print('Error deleting Jadwal Obat: $e');
      return false;
    }
  }

  // --- 5. Ambil Tinjauan Obat Harian (Dibiarkan sama) ---
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

  //--6 Tambahkan fungsi Tambah Jadwal Obat
  static Future<bool> addObat(JadwalObat obat) async {
    try {
      final response = await supabase.from('jadwalobat').insert({
        'id_pengguna': _currentUserId, // Menggunakan ID Pengguna saat ini
        'nama_obat': obat.namaObat,
        'jumlah_obat': obat.jumlahObat,
        'durasi_hari': obat.durasiHari,
        'jenis_waktu_makan': obat.jenisWaktuMakan,
        'jam_minum':
            '${obat.jamMinum.hour.toString().padLeft(2, '0')}:${obat.jamMinum.minute.toString().padLeft(2, '0')}:00',
        'catatan': obat.catatan,
        'status': false, // Default status: Belum selesai (false)
      }).select();

      return response.isNotEmpty;
    } catch (e) {
      print('Error adding Jadwal Obat: $e');
      return false;
    }
  }
}
