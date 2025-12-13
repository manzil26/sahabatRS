import 'package:flutter/material.dart';

class JadwalObat {
  final int id;
  final String idPengguna; // UBAH KE STRING (UUID)
  final String namaObat;
  final TimeOfDay jamMinum;
  final String jenisWaktuMakan;
  final bool statusSelesai;
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

  factory JadwalObat.fromJson(Map<String, dynamic> json) {
    String timeString = json['jam_minum'];
    List<String> parts = timeString.split(':');

    TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    return JadwalObat(
      id: json['id_jadwalobat'],
      idPengguna: json['id_pengguna'].toString(), // Pastikan jadi String
      namaObat: json['nama_obat'],
      jamMinum: parsedTime,
      jenisWaktuMakan: json['jenis_waktu_makan'] ?? 'sebelum_makan',
      statusSelesai: json['status'] ?? false,
      jumlahObat: json['jumlah_obat'],
      durasiHari: json['durasi_hari'],
      catatan: json['catatan'],
    );
  }
}