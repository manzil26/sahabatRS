import 'package:flutter/material.dart'; // Tetap diperlukan untuk TimeOfDay

class JadwalCheckUpDetail {
  final int idCheckup;
  final DateTime tanggal;
  // Kolom 'lokasi' dari tabel 'checkup' menggantikan 'namaRumahSakit'
  final String lokasi;
  // Kolom 'kegiatan' dari tabel 'checkup' menggantikan 'namaPoli'
  final String kegiatan;
  // Kolom 'kondisi_tambahan' dari tabel 'checkup' menggantikan 'kondisiPengguna'
  final String kondisiTambahan;

  // Menambahkan kolom waktu notifikasi jika diperlukan di model
  final TimeOfDay? waktuNotifikasi;

  JadwalCheckUpDetail({
    required this.idCheckup,
    required this.tanggal,
    required this.lokasi,
    required this.kegiatan,
    required this.kondisiTambahan,
    this.waktuNotifikasi,
  });

  // Factory method untuk mapping dari tabel 'checkup'
  factory JadwalCheckUpDetail.fromMap(Map<String, dynamic> map) {
    // 1. Parsing tanggal (DATE)
    DateTime parsedDate = DateTime.parse(map['tanggal']);

    // 2. Parsing waktu notifikasi (TIME) jika ada
    TimeOfDay? parsedTime;
    if (map['waktu_notifikasi'] != null) {
      String timeString = map['waktu_notifikasi']; // Format "HH:MM:SS"
      List<String> parts = timeString.split(':');
      parsedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return JadwalCheckUpDetail(
      idCheckup: map['id_checkup'],
      tanggal: parsedDate,
      lokasi: map['lokasi'] ?? 'Lokasi Tidak Diketahui',
      kegiatan: map['kegiatan'] ?? 'Kegiatan Tidak Dicatat',
      kondisiTambahan: map['kondisi_tambahan'] ?? 'Tidak ada kondisi tambahan',
      waktuNotifikasi: parsedTime,
    );
  }
}