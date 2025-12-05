// import '../models/jadwal_obat.dart';

// class JadwalService {
//   // Simulasi data untuk jadwal Check-Up
//   static DateTime getJadwalCheckUp() {
//     // Di aplikasi nyata, ini akan diambil dari tabel 'jadwal'
//     // Misalnya, return DateTime.parse('2025-10-08');
//     return DateTime(2025, 10, 8);
//   }

//   // Simulasi data untuk Tinjauan Obat Harian
//   static List<JadwalObat> getTinjauanObatHarian() {
//     // Di aplikasi nyata, ini akan diambil dari tabel 'jadwalobat'
//     // dengan filter berdasarkan id_pengguna dan tanggal hari ini
//     return [
//       JadwalObat(
//         id: 1,
//         namaObat: 'Sanmol',
//         waktuMinum: DateTime(
//           DateTime.now().year,
//           DateTime.now().month,
//           DateTime.now().day,
//           10,
//           0,
//         ),
//         status: 'Selesai',
//       ),
//       JadwalObat(
//         id: 2,
//         namaObat: 'Panadol',
//         waktuMinum: DateTime(
//           DateTime.now().year,
//           DateTime.now().month,
//           DateTime.now().day,
//           16,
//           0,
//         ),
//         status: 'Terlewat',
//       ),
//       JadwalObat(
//         id: 3,
//         namaObat: 'Betanol',
//         waktuMinum: DateTime(
//           DateTime.now().year,
//           DateTime.now().month,
//           DateTime.now().day,
//           16,
//           0,
//         ),
//         status: 'Skip',
//       ),
//       JadwalObat(
//         id: 4,
//         namaObat: 'Amoxilin',
//         waktuMinum: DateTime(
//           DateTime.now().year,
//           DateTime.now().month,
//           DateTime.now().day,
//           16,
//           0,
//         ),
//         status: 'Terlewat',
//       ),
//       JadwalObat(
//         id: 5,
//         namaObat: 'Neurobion',
//         waktuMinum: DateTime(
//           DateTime.now().year,
//           DateTime.now().month,
//           DateTime.now().day,
//           16,
//           0,
//         ),
//         status: 'Terlewat',
//       ),
//     ];
//   }
// }
// lib/services/jadwal_service.dart
// lib/services/jadwal_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jadwal_obat.dart';

// Dapatkan instance client Supabase
final supabase = Supabase.instance.client;

class JadwalService {
  // Asumsi: ID pengguna yang sedang login
  // Ganti dengan ID pengguna dinamis dari sesi/autentikasi Supabase Anda
  static const int _currentUserId = 1;

  // --- 1. Ambil Jadwal Check-Up dari tabel 'jadwal' ---
  // Tipe kembalian sudah benar: Future<DateTime?> (tipe DATE di SQL)
  static Future<DateTime?> getJadwalCheckUp() async {
    try {
      final response = await supabase
          .from('jadwal')
          .select('tanggal')
          .eq('id_pengguna', _currentUserId)
          .order('tanggal', ascending: true)
          .limit(1)
          .single();

      if (response['tanggal'] != null) {
        // Kolom tanggal adalah tipe DATE, parse langsung
        return DateTime.parse(response['tanggal']);
      }
      return null;
    } catch (e) {
      print('Error fetching Jadwal Check-Up: $e');
      return null;
    }
  }

  // --- 2. Ambil Tinjauan Obat Harian dari tabel 'jadwalobat' ---
  // Tipe kembalian sudah benar: Future<List<JadwalObat>>
  static Future<List<JadwalObat>> getTinjauanObatHarian() async {
    try {
      // Query ke tabel jadwalobat
      final List<Map<String, dynamic>> response = await supabase
          .from('jadwalobat')
          .select('*')
          .eq('id_pengguna', _currentUserId)
          .order(
            'jam_minum',
            ascending: true,
          ); // Urutkan berdasarkan waktu (TIME)

      // Mapping data ke model yang sudah diperbaiki
      return response.map((data) => JadwalObat.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching Tinjauan Obat Harian: $e');
      return [];
    }
  }
}
