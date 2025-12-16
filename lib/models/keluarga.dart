// MODEL untuk tabel `keluarga` (orang terdekat user)
class Keluarga {
  final int idKeluarga;
  final String namaLengkap;
  final String nomorTelepon;
  final String? hubungan;

  Keluarga({
    required this.idKeluarga,
    required this.namaLengkap,
    required this.nomorTelepon,
    this.hubungan,
  });

  factory Keluarga.fromMap(Map<String, dynamic> map) {
    return Keluarga(
      idKeluarga: map['id_keluarga'] as int,
      namaLengkap: map['nama_lengkap'] as String,
      nomorTelepon: map['nomor_telepon'] as String,
      hubungan: map['hubungan'] as String?,
    );
  }
}
