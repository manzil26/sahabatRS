import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sahabat_rs/models/lacak_pendampingan.dart';
import 'package:sahabat_rs/services/salacak_service.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/sadar_pengantaran_selesai.dart';

/// HALAMAN Tracking SaLacak
/// - Jika idRiwayatPesanan != null -> ambil timeline dari DB (polling tiap 5 detik)
/// - Jika idRiwayatPesanan == null -> simulasi realtime (muncul bertahap tiap beberapa detik)
class SaLacakTrackingPage extends StatefulWidget {
  final int? idRiwayatPesanan;

  /// waktu saat tombol ditekan (biar simulasi realtime & tanggal sesuai saat klik)
  final DateTime? pressedAt;

  const SaLacakTrackingPage({
    super.key,
    this.idRiwayatPesanan,
    this.pressedAt,
  });

  @override
  State<SaLacakTrackingPage> createState() => _SaLacakTrackingPageState();
}

class _SaLacakTrackingPageState extends State<SaLacakTrackingPage> {
  bool _loading = true;
  String? _error;

  // timeline dari DB (kalau ada idRiwayatPesanan)
  List<LacakPendampingan> _dbTimeline = [];

  // waktu "sekarang" untuk simulasi realtime
  DateTime _now = DateTime.now();
  Timer? _tickTimer;
  Timer? _pollTimer;

  late final DateTime _pressedAt;

  @override
  void initState() {
    super.initState();
    _pressedAt = widget.pressedAt ?? DateTime.now();

    // update waktu tiap 1 detik (biar simulasi realtime jalan tanpa refresh)
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });

    _loadTimeline();

    // kalau pakai DB, polling biar “realtime”
    if (widget.idRiwayatPesanan != null) {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _loadTimeline(silent: true);
      });
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimeline({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      if (widget.idRiwayatPesanan == null) {
        // mode simulasi -> tidak fetch DB
        if (!mounted) return;
        setState(() {
          _dbTimeline = [];
          _loading = false;
        });
        return;
      }

      final fetched =
          await SaLacakService.getPelacakan(widget.idRiwayatPesanan!);
      fetched.sort((a, b) => b.waktu.compareTo(a.waktu));

      if (!mounted) return;
      setState(() {
        _dbTimeline = fetched;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat pelacakan: $e';
      });
    }
  }

  /// SIMULASI REALTIME (tanpa pendamping app):
  /// item akan "muncul" bertahap sesuai detik dari pressedAt
  List<LacakPendampingan> _simulatedTimelineVisible() {
    final base = _pressedAt;

    DateTime atSeconds(int s) => base.add(Duration(seconds: s));

    // Muncul cepat: total 15 detik
    final all = <LacakPendampingan>[
      LacakPendampingan(
        idPelacakan: 1,
        idRiwayatPesanan: 1,
        aktivitas: "Penjemputan pasien",
        status: "dijemput",
        waktu: atSeconds(0),
      ),
      LacakPendampingan(
        idPelacakan: 2,
        idRiwayatPesanan: 1,
        aktivitas: "Tiba di Rumah Sakit",
        status: "di_rs",
        waktu: atSeconds(3),
      ),
      LacakPendampingan(
        idPelacakan: 3,
        idRiwayatPesanan: 1,
        aktivitas: "Administrasi pendaftaran selesai",
        status: "di_rs",
        waktu: atSeconds(6),
      ),
      LacakPendampingan(
        idPelacakan: 4,
        idRiwayatPesanan: 1,
        aktivitas: "Medical Check-Up pada poli mata selesai",
        status: "di_rs",
        waktu: atSeconds(9),
      ),
      LacakPendampingan(
        idPelacakan: 5,
        idRiwayatPesanan: 1,
        aktivitas: "Pengambilan obat selesai",
        status: "di_rs",
        waktu: atSeconds(12),
      ),
      LacakPendampingan(
        idPelacakan: 6,
        idRiwayatPesanan: 1,
        aktivitas: "Pasien telah kembali ke rumah",
        status: "selesai",
        waktu: atSeconds(15),
      ),
    ];

    // tampilkan hanya yang waktunya sudah lewat (biar berasa realtime)
    final visible = all.where((x) => !x.waktu.isAfter(_now)).toList();
    visible.sort((a, b) => b.waktu.compareTo(a.waktu));
    return visible;
  }

  _StepState _deriveStepState(List<LacakPendampingan> timeline) {
    if (timeline.isEmpty) {
      return const _StepState(
        penjemputan: true,
        rs: false,
        pengantaran: false,
      );
    }

    final latest = timeline.first;
    final s = latest.status.toLowerCase();

    if (s.contains('selesai')) {
      return const _StepState(penjemputan: true, rs: true, pengantaran: true);
    }
    if (s.contains('di_rs') || s.contains('rs')) {
      return const _StepState(penjemputan: true, rs: true, pengantaran: false);
    }
    if (s.contains('dijemput') || s.contains('jemput')) {
      return const _StepState(penjemputan: true, rs: false, pengantaran: false);
    }

    return const _StepState(penjemputan: true, rs: true, pengantaran: false);
  }

  @override
  Widget build(BuildContext context) {
    final timeline = widget.idRiwayatPesanan == null
        ? _simulatedTimelineVisible()
        : _dbTimeline;

    final steps = _deriveStepState(timeline);

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
              // HEADER
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SadarPengantaranSelesai(),
                            ),
                          );
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

              // CARD STEP (sesuai mockup)
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
                    children: [
                      _StepItem(
                        label: "Penjemputan\nPasien",
                        active: steps.penjemputan,
                      ),
                      const _StepConnector(),
                      _StepItem(
                        label: "Rumah\nSakit",
                        active: steps.rs,
                      ),
                      const _StepConnector(),
                      _StepItem(
                        label: "Pengantaran\nPasien",
                        active: steps.pengantaran,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CARD TIMELINE
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

                        if (_loading)
                          const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null)
                          Expanded(
                            child: Center(
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        else if (timeline.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                widget.idRiwayatPesanan == null
                                    ? "Menunggu proses berjalan..."
                                    : "Belum ada update pendampingan.",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: timeline.length,
                              itemBuilder: (context, index) {
                                final item = timeline[index];
                                final isFirst = index == 0;
                                final isLast = index == timeline.length - 1;

                                return _TimelineRow(
                                  data: item,
                                  isFirst: isFirst,
                                  isLast: isLast,
                                );
                              },
                            ),
                          ),
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
}

class _StepState {
  final bool penjemputan;
  final bool rs;
  final bool pengantaran;

  const _StepState({
    required this.penjemputan,
    required this.rs,
    required this.pengantaran,
  });
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFC63A) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
    final dateLabel = DateFormat("dd MMM", "id_ID").format(data.waktu);
    final timeLabel = DateFormat("HH:mm", "id_ID").format(data.waktu);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                timeLabel,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
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
                height: 46,
                color: const Color(0xFF567DF4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
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
