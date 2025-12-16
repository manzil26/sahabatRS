// lib/models/lacak_pendampingan.dart

/// MODEL untuk tabel `lacak` (timeline pendampingan)
class LacakPendampingan {
  final int idPelacakan;
  final int idRiwayatPesanan;
  final String aktivitas;
  final String status;
  final DateTime waktu; // gabungan tanggal + jam

  LacakPendampingan({
    required this.idPelacakan,
    required this.idRiwayatPesanan,
    required this.aktivitas,
    required this.status,
    required this.waktu,
  });

  factory LacakPendampingan.fromMap(Map<String, dynamic> map) {
    final dynamic tanggalRaw = map['tanggal'];
    final dynamic jamRaw = map['jam'];

    final DateTime tanggal = tanggalRaw is String
        ? DateTime.parse(tanggalRaw)
        : (tanggalRaw as DateTime);

    final String jamString = jamRaw is String
        ? jamRaw
        : (jamRaw as DateTime).toIso8601String().split('T')[1];

    final parts = jamString.split(':');
    final int hh = int.parse(parts[0]);
    final int mm = int.parse(parts[1]);

    final DateTime waktu = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      hh,
      mm,
    );

    return LacakPendampingan(
      idPelacakan: map['id_pelacakan'] as int,
      idRiwayatPesanan: map['id_riwayatpesanan'] as int,
      aktivitas: map['aktivitas_pendampingan'] as String,
      status: map['status'] as String,
      waktu: waktu,
    );
  }
}
