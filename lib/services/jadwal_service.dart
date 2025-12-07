import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jadwal_obat.dart';
import '../models/jadwal_checkup_detail.dart';

// Dapatkan instance client Supabase
final supabase = Supabase.instance.client;

class JadwalService {
  // Mengambil ID User yang sedang login secara dinamis
  static String get _currentUserId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User belum login");
    }
    return user.id;
  }

  // --- 1. Ambil Jadwal Check-Up berikutnya ---
  static Future<JadwalCheckUpDetail?> getNextJadwalCheckUpDetail() async {
    try {
      final response = await supabase
          .from('checkup')
          .select(
            'id_checkup, tanggal, lokasi, kegiatan, kondisi_tambahan, waktu_notifikasi',
          )
          .eq('id_pengguna', _currentUserId) // Menggunakan UUID user
          .gte('tanggal', DateTime.now().toIso8601String().split('T')[0])
          .order('tanggal', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return JadwalCheckUpDetail.fromMap(response);
    } catch (e) {
      print('Error fetching Next Jadwal Check-Up Detail: $e');
      return null;
    }
  }

  // --- 2. Ambil Jadwal Check-Up berdasarkan Tanggal ---
  static Future<JadwalCheckUpDetail?> getCheckupByDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];

    try {
      final response = await supabase
          .from('checkup')
          .select(
            'id_checkup, tanggal, lokasi, kegiatan, kondisi_tambahan, waktu_notifikasi',
          )
          .eq('id_pengguna', _currentUserId)
          .eq('tanggal', dateString)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return JadwalCheckUpDetail.fromMap(response);
    } catch (e) {
      print('Error fetching Checkup by Date ($dateString): $e');
      return null;
    }
  }

  // --- 3. Ambil SEMUA Jadwal Check-Up untuk Kalender ---
  static Future<List<DateTime>> getAllJadwalDates() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('checkup')
          .select('tanggal')
          .eq('id_pengguna', _currentUserId)
          .order('tanggal', ascending: true);

      return response.map((data) => DateTime.parse(data['tanggal'])).toList();
    } catch (e) {
      print('Error fetching All Jadwal Dates: $e');
      return [];
    }
  }

  // --- 4. Ambil Tinjauan Obat Harian ---
  static Future<List<JadwalObat>> getTinjauanObatHarian() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('jadwalobat')
          .select('*')
          .eq('id_pengguna', _currentUserId)
          .order('jam_minum', ascending: true);

      return response.map((data) => JadwalObat.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching Tinjauan Obat Harian: $e');
      return [];
    }
  }

  // --- 5. Update Jadwal Obat ---
  static Future<bool> updateObat(JadwalObat obat) async {
    try {
      await supabase
          .from('jadwalobat')
          .update({
            'nama_obat': obat.namaObat,
            'jumlah_obat': obat.jumlahObat,
            'durasi_hari': obat.durasiHari,
            'jenis_waktu_makan': obat.jenisWaktuMakan,
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

  // --- 6. Hapus Jadwal Obat ---
  static Future<bool> deleteObat(int idObat) async {
    try {
      await supabase.from('jadwalobat').delete().eq('id_jadwalobat', idObat);
      return true;
    } catch (e) {
      print('Error deleting Jadwal Obat: $e');
      return false;
    }
  }

  // --- 7. Tambah Jadwal Obat ---
  static Future<bool> addObat(JadwalObat obat) async {
    try {
      final response = await supabase.from('jadwalobat').insert({
        'id_pengguna': _currentUserId,
        'nama_obat': obat.namaObat,
        'jumlah_obat': obat.jumlahObat,
        'durasi_hari': obat.durasiHari,
        'jenis_waktu_makan': obat.jenisWaktuMakan,
        'jam_minum':
            '${obat.jamMinum.hour.toString().padLeft(2, '0')}:${obat.jamMinum.minute.toString().padLeft(2, '0')}:00',
        'catatan': obat.catatan,
        'status': false,
      }).select();

      return response.isNotEmpty;
    } catch (e) {
      print('Error adding Jadwal Obat: $e');
      return false;
    }
  }

  // --- 8. Tambah Jadwal Checkup ---
  static Future<bool> addCheckup(JadwalCheckUpDetail detail) async {
    try {
      final response = await supabase.from('checkup').insert({
        'id_pengguna': _currentUserId,
        'tanggal': detail.tanggal.toIso8601String().split('T')[0],
        'lokasi': detail.lokasi,
        'kegiatan': detail.kegiatan,
        'kondisi_tambahan': detail.kondisiTambahan,
        'waktu_notifikasi':
            '${detail.waktuNotifikasi!.hour.toString().padLeft(2, '0')}:${detail.waktuNotifikasi!.minute.toString().padLeft(2, '0')}:00',
      }).select();

      return response.isNotEmpty;
    } catch (e) {
      print('Error adding Jadwal Checkup: $e');
      return false;
    }
  }

  // --- 9. Update Jadwal Checkup ---
  static Future<bool> updateCheckup(JadwalCheckUpDetail detail) async {
    try {
      await supabase
          .from('checkup')
          .update({
            'tanggal': detail.tanggal.toIso8601String().split('T')[0],
            'lokasi': detail.lokasi,
            'kegiatan': detail.kegiatan,
            'kondisi_tambahan': detail.kondisiTambahan,
            'waktu_notifikasi':
                '${detail.waktuNotifikasi!.hour.toString().padLeft(2, '0')}:${detail.waktuNotifikasi!.minute.toString().padLeft(2, '0')}:00',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_checkup', detail.idCheckup)
          .select();
      return true;
    } catch (e) {
      print('Error updating Jadwal Checkup: $e');
      return false;
    }
  }

  // --- 10. Hapus Jadwal Checkup ---
  static Future<bool> deleteCheckup(int idCheckup) async {
    try {
      await supabase.from('checkup').delete().eq('id_checkup', idCheckup);
      return true;
    } catch (e) {
      print('Error deleting Jadwal Checkup: $e');
      return false;
    }
  }
}