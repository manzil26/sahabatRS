import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahabat_rs/models/lacak_pendampingan.dart';
import 'package:sahabat_rs/services/salacak_service.dart'; // <-- PENTING

/// HALAMAN Tracking SaLacak
/// - Dipanggil ketika tekan "Lacak Pendampingan"
class SaLacakTrackingPage extends StatelessWidget {
  final int? idRiwayatPesanan;

  const SaLacakTrackingPage({
    super.key,
    this.idRiwayatPesanan,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE:
    // - Kalau idRiwayatPesanan == null → pakai dummy agar UI tetap tampil
    // - Kalau dikirim (mis. dari riwayat) → ambil dari Supabase
    final Future<List<LacakPendampingan>> futureTimeline =
        idRiwayatPesanan == null
            ? Future.value(_dummyTimeline())
            : SaLacakService.getPelacakan(idRiwayatPesanan!);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE7A0), Color(0xFFFFD27F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER + tombol back
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () {
                          // selalu balik ke halaman sebelumnya
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Lacak Pendamping",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // CARD step proses (Penjemputan - RS - Pengantaran)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StepItem(
                        label: "Penjemputan\nPasien",
                        active: true,
                      ),
                      _StepConnector(),
                      _StepItem(
                        label: "Rumah\nSakit",
                        active: true,
                      ),
                      _StepConnector(),
                      _StepItem(
                        label: "Pengantaran\nPasien",
                        active: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CARD timeline
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pelacakan Proses Pendampingan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<List<LacakPendampingan>>(
                            future: futureTimeline,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final list = snapshot.data ?? [];

                              if (list.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Belum ada update pendampingan.",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }

                              // Urutkan dari yang terbaru ke paling lama
                              list.sort(
                                  (a, b) => b.waktu.compareTo(a.waktu));

                              return ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final item = list[index];
                                  final isFirst = index == 0;
                                  final isLast = index == list.length - 1;
                                  return _TimelineRow(
                                    data: item,
                                    isFirst: isFirst,
                                    isLast: isLast,
                                  );
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Data dummy supaya UI sama persis contoh ketika DB belum ada data
  List<LacakPendampingan> _dummyTimeline() {
    final tanggal = DateTime(2025, 7, 27);
    DateTime t(int hh, int mm) =>
        DateTime(tanggal.year, tanggal.month, tanggal.day, hh, mm);

    return [
      LacakPendampingan(
        idPelacakan: 1,
        idRiwayatPesanan: 1,
        aktivitas: "Pasien telah kembali ke rumah",
        status: "selesai",
        waktu: t(11, 20),
      ),
      LacakPendampingan(
        idPelacakan: 2,
        idRiwayatPesanan: 1,
        aktivitas: "Pengambilan obat selesai",
        status: "di_rs",
        waktu: t(11, 00),
      ),
      LacakPendampingan(
        idPelacakan: 3,
        idRiwayatPesanan: 1,
        aktivitas: "Medical Check-Up pada poli mata selesai",
        status: "di_rs",
        waktu: t(10, 45),
      ),
      LacakPendampingan(
        idPelacakan: 4,
        idRiwayatPesanan: 1,
        aktivitas: "Administrasi pendaftaran selesai",
        status: "di_rs",
        waktu: t(10, 15),
      ),
      LacakPendampingan(
        idPelacakan: 5,
        idRiwayatPesanan: 1,
        aktivitas: "Tiba di Rumah Sakit",
        status: "di_rs",
        waktu: t(10, 00),
      ),
      LacakPendampingan(
        idPelacakan: 6,
        idRiwayatPesanan: 1,
        aktivitas: "Penjemputan pasien",
        status: "dijemput",
        waktu: t(9, 46),
      ),
    ];
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final bool active;

  const _StepItem({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF567DF4) : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color(0xFF567DF4),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final LacakPendampingan data;
  final bool isFirst;
  final bool isLast;

  const _TimelineRow({
    required this.data,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final tanggalLabel =
        DateFormat("dd MMM\nHH:mm", "id_ID").format(data.waktu);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // tanggal + jam
        SizedBox(
          width: 60,
          child: Text(
            tanggalLabel,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // bullet + garis
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC63A),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFF567DF4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // deskripsi aktivitas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              data.aktivitas,
              style: TextStyle(
                fontSize: 13,
                color: isFirst ? const Color(0xFF567DF4) : Colors.black87,
                fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
