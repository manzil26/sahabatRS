// screens/penjadwalan/jadwal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/jadwal_service.dart';
import '../../../../models/jadwal_checkup_detail.dart';
// 👇 TAMBAHKAN IMPORT HALAMAN BARU 👇
import 'tambah-jadwal-checkup.dart';

// --- Konstanta Warna ---
const Color _orangeAksen = Color(0xFFFC770F);
const Color _kuningCheckUp = Color(0xFFFCDD7A); // Warna kuning dari SajadHome
const Color _biruGelapIcon = Color(0xFF5966B1);

// --- Widget Kustom untuk Tag Kondisi (TIDAK BERUBAH) ---
class KondisiTag extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const KondisiTag({
    Key? key,
    required this.text,
    this.color = _kuningCheckUp,
    this.textColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// --- Halaman Utama Jadwal Check-Up ---
class JadwalPage extends StatefulWidget {
  const JadwalPage({Key? key}) : super(key: key);

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late Future<JadwalCheckUpDetail?> _futureNextCheckUp;
  late Future<List<DateTime>> _futureAllJadwalDates;

  // STATE BARU UNTUK BULAN YANG SEDANG DILIHAT
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _futureNextCheckUp = JadwalService.getNextJadwalCheckUpDetail();
    _futureAllJadwalDates = JadwalService.getAllJadwalDates();
  }

  void _refreshData() {
    setState(() {
      _fetchData();
    });
  }

  // Fungsi untuk berpindah bulan
  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    });
  }

  // --- Widget Builder untuk Kalender Sederhana (Sekarang Dinamis) ---
  Widget _buildCalendar(
    List<DateTime> allJadwalDates,
    DateTime nextJadwalDate,
  ) {
    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // MENGGUNAKAN _focusedDay UNTUK MENDAPATKAN BULAN SAAT INI
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final int firstWeekday = startOfMonth.weekday;
    final int daysInMonth = endOfMonth.day;

    // Menghitung offset (Minggu = 7 di Dart, kita sesuaikan ke 0)
    final int startOffset = (firstWeekday == 7) ? 0 : firstWeekday;

    final List<Widget> calendarDays = [];

    // Tambahkan widget kosong untuk offset awal
    for (int i = 0; i < startOffset; i++) {
      calendarDays.add(const SizedBox.shrink());
    }

    // Tambahkan hari-hari di bulan
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(startOfMonth.year, startOfMonth.month, day);
      // Logika styling hardcoded untuk tampilan yang mirip gambar (Oktober 2025)
      final bool isToday =
          (currentDate.day == 7 &&
          currentDate.month == 10 &&
          currentDate.year == 2025);
      final bool isScheduled = allJadwalDates.any(
        (d) => isSameDay(d, currentDate),
      );

      BoxDecoration decoration;
      Color textColor = Colors.black;

      if (isToday) {
        decoration = BoxDecoration(
          border: Border.all(color: _biruGelapIcon, width: 2),
          shape: BoxShape.circle,
        );
      } else if (isScheduled) {
        decoration = BoxDecoration(
          color: _kuningCheckUp,
          shape: BoxShape.circle,
          border: Border.all(color: _orangeAksen, width: 1),
        );
        textColor = Colors.black;
      } else {
        decoration = const BoxDecoration();
      }

      calendarDays.add(
        Container(
          alignment: Alignment.center,
          decoration: decoration,
          child: Text(
            day.toString(),
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bulan Tahun dengan Tombol Navigasi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => _changeMonth(-1),
            ),

            // Judul Bulan Tahun
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Header Hari (S, M, T, W, T, F, S)
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'S',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'M',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'T',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'W',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'T',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'F',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              'S',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid Tanggal
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: calendarDays,
        ),
      ],
    );
  }

  // --- Widget Builder untuk Kartu Detail Check-Up (TIDAK BERUBAH) ---
  Widget _buildDetailCard(JadwalCheckUpDetail detail) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(detail.tanggal);

    // Memecah string kondisi menjadi list tag (Menggunakan properti baru)
    final List<String> kondisiList = detail.kondisiTambahan
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty) // Hilangkan string kosong
        .toList();

    // Fungsi pembangun baris detail
    Widget _buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medical Check-Up Selanjutnya',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 15),

          // Detail
          _buildDetailRow('Tanggal', formattedDate),
          _buildDetailRow('Rumah Sakit', detail.lokasi), // Menggunakan 'lokasi'
          _buildDetailRow(
            'Kegiatan',
            detail.kegiatan, // Menggunakan 'kegiatan'
          ),

          // Kondisi (Tags)
          const Text(
            'Kondisi',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: kondisiList.map((kondisi) {
              return KondisiTag(
                text: kondisi,
                color: _kuningCheckUp.withOpacity(0.7),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Widget Utama Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Jadwal Check-Up',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: _biruGelapIcon),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download, color: _orangeAksen),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),

      body: FutureBuilder<JadwalCheckUpDetail?>(
        future: _futureNextCheckUp,
        builder: (context, snapshotDetail) {
          return FutureBuilder<List<DateTime>>(
            future: _futureAllJadwalDates,
            builder: (context, snapshotDates) {
              if (snapshotDetail.connectionState == ConnectionState.waiting ||
                  snapshotDates.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshotDetail.hasError || snapshotDates.hasError) {
                print(snapshotDetail.error);
                return const Center(child: Text('Gagal memuat data jadwal.'));
              }

              // Data Jadwal Check-Up
              final JadwalCheckUpDetail? nextJadwal = snapshotDetail.data;
              final List<DateTime> allJadwalDates = snapshotDates.data ?? [];

              // Kalender memerlukan tanggal untuk menandai hari ini dan hari terjadwal
              final DateTime nextDate = nextJadwal?.tanggal ?? DateTime.now();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Kalender (Dinamis)
                    _buildCalendar(allJadwalDates, nextDate),

                    // Kartu Detail
                    if (nextJadwal != null)
                      _buildDetailCard(nextJadwal)
                    else
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'Tidak ada jadwal check-up yang akan datang.',
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // Floating Action Button Tambah Jadwal
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 👇 LOGIKA NAVIGASI KE TAMBAH JADWAL CHECKUP 👇
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahJadwalCheckupPage(),
            ),
          ).then((_) => _refreshData());
          // 👆 LOGIKA NAVIGASI KE TAMBAH JADWAL CHECKUP 👆
        },
        backgroundColor: _orangeAksen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
