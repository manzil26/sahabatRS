// lib/models/jadwal_obat.dart
import 'package:flutter/material.dart'; // Dibutuhkan untuk TimeOfDay

class JadwalObat {
  final int id;
  final int idPengguna; // id_pengguna
  final String namaObat; // nama_obat
  final TimeOfDay jamMinum; // jam_minum (TIME di SQL)
  final String jenisWaktuMakan; // jenis_waktu_makan (ENUM di SQL)
  final bool statusSelesai; // status (BOOLEAN di SQL)

  // Kolom lain dari tabel jadwalobat
  final int? jumlahObat;
  final int? durasiHari;
  final String? catatan;

  JadwalObat({
    required this.id,
    required this.idPengguna,
    required this.namaObat,
    required this.jamMinum,
    required this.jenisWaktuMakan,
    required this.statusSelesai,
    this.jumlahObat,
    this.durasiHari,
    this.catatan,
  });

  // Factory Method untuk Supabase/JSON Mapping
  factory JadwalObat.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Jam Minum (TIME) dari Supabase
    // Supabase mengembalikan TIME sebagai string "HH:MM:SS" (misal: "10:00:00")
    String timeString = json['jam_minum'];
    List<String> parts = timeString.split(':');

    TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(parts[0]), // Jam (HH)
      minute: int.parse(parts[1]), // Menit (MM)
    );

    return JadwalObat(
      id: json['id_jadwalobat'],
      idPengguna: json['id_pengguna'],
      namaObat: json['nama_obat'],
      jamMinum: parsedTime,
      // Karena ENUM, langsung pakai String
      jenisWaktuMakan: json['jenis_waktu_makan'] ?? 'sebelum_makan',
      statusSelesai: json['status'] ?? false, // Default: false (belum selesai)
      // Kolom opsional
      jumlahObat: json['jumlah_obat'],
      durasiHari: json['durasi_hari'],
      catatan: json['catatan'],
    );
  }
}
