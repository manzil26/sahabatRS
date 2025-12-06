import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sajad-tambah.dart'; // Import halaman tujuan Anda

// Pastikan import model dan service sudah benar
import '../../../../models/jadwal_obat.dart'; // Sesuaikan path jika perlu
import '../../../../services/jadwal_service.dart'; // Sesuaikan path jika perlu

// --- Kode Warna Khusus dari Gambar ---
// Kuning Pastel untuk Check-Up Card (mirip dengan #FCE69B atau yang ada di gambar)
const Color _kuningCheckUp = Color(0xFFFCDD7A);
// Orange/Filter Button Color
const Color _orangeAksen = Color(0xFFFC770F);
// Warna Icon Biru Gelap/Ungu (dari icon Bantuan)
const Color _biruGelapIcon = Color(0xFF5966B1);

// Ukuran standar untuk wadah icon button kecil di appbar
const double _kIconButtonSize = 30.0;

// --- Widget Kustom untuk Item Obat ---
class ObatItem extends StatelessWidget {
  final JadwalObat obat;

  const ObatItem({Key? key, required this.obat}) : super(key: key);

  String getStatusText(bool isSelesai, TimeOfDay jam) {
    // Simulasi Status 'Skip'
    if (obat.namaObat == 'Betanol') {
      return 'Skip';
    }

    if (isSelesai) return 'Selesai';

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      jam.hour,
      jam.minute,
    );

    if (now.isAfter(scheduledTime)) {
      return 'Terlewat';
    }
    return 'Belum Diminum';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green[700]!;
      case 'Terlewat':
        return Colors.red;
      case 'Skip':
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan Icon Obat (diganti menjadi Image.asset)
  Widget getObatIconWidget() {
    // Menggunakan Image.asset sesuai niat Anda
    return Image.asset(
      'assets/images/penjadwalan/pil.png', // Ganti dengan path gambar Anda
      width: 24, // Ukuran Ikon Pil disesuaikan
      height: 24,
      color:
          Colors.grey[600], // Sesuaikan warna jika gambar adalah PNG monokrom
    );
  }

  @override
  Widget build(BuildContext context) {
    // KODE Image.asset YANG SALAH DIHAPUS DARI SINI

    // Memformat TimeOfDay menjadi String
    final formattedTime = obat.jamMinum.format(context);

    // Dapatkan status berdasarkan logika dan nama obat untuk simulasi 'Skip'
    final statusText = getStatusText(obat.statusSelesai, obat.jamMinum);
    final statusColor = getStatusColor(statusText);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: const Color(0xFFF8F8F6), // Warna latar belakang Card
        borderRadius: BorderRadius.circular(15),
        elevation: 1, // Memberikan sedikit bayangan
        child: InkWell(
          onTap: () {
            print('Detail ${obat.namaObat}');
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16), // Padding di dalam Card
            child: Row(
              children: [
                // Icon Obat (Menggunakan Widget kustom yang sudah memuat Image.asset)
                getObatIconWidget(), // Icon/Gambar Pil

                const SizedBox(width: 15),
                // Nama Obat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat.namaObat,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Waktu dan Status
                      Row(
                        children: [
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '• $statusText', // Tambahkan titik pemisah
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Panah (>)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Halaman Utama Sajad Home (Tidak Ada Perubahan Logika Utama) ---
class SajadHomePage extends StatefulWidget {
  const SajadHomePage({Key? key}) : super(key: key);

  @override
  State<SajadHomePage> createState() => _SajadHomePageState();
}

class _SajadHomePageState extends State<SajadHomePage> {
  late Future<DateTime?> _futureJadwalCheckUp;
  late Future<List<JadwalObat>> _futureListObat;

  @override
  void initState() {
    super.initState();
    // Panggil service untuk mendapatkan data
    _futureJadwalCheckUp = JadwalService.getJadwalCheckUp();
    _futureListObat = JadwalService.getTinjauanObatHarian();
  }

  // Widget Builder untuk Jadwal Check-Up (Tidak Berubah)
  Widget _buildCheckUpCard() {
    return FutureBuilder<DateTime?>(
      future: _futureJadwalCheckUp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LinearProgressIndicator(
              color: _kuningCheckUp,
              backgroundColor: _kuningCheckUp.withOpacity(0.3),
            ),
          );
        }

        DateTime? jadwal = snapshot.data;
        String tanggalCheckUp = jadwal != null
            ? DateFormat('dd MMMM yyyy').format(jadwal)
            : 'Belum ada jadwal';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kuningCheckUp,
            borderRadius: BorderRadius.circular(20), // Border lebih melingkar
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jadwal Check-Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selanjutnya pada',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      tanggalCheckUp, // Menampilkan tanggal
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Warna teks hitam
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        print('Lihat Detail Check-Up');
                      },
                      child: const Text(
                        'Selengkapnya',
                        style: TextStyle(
                          color: _biruGelapIcon, // Warna biru gelap
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Image - sesuaikan ukuran dan path
              Image.asset(
                'assets/images/penjadwalan/notes.png', // Ganti dengan path gambar Anda
                width: 200, // Sesuaikan lebar
                height: 200, // Sesuaikan tinggi
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget Builder untuk Daftar Obat Harian (Tidak Berubah)
  Widget _buildDailyMedicationList() {
    return FutureBuilder<List<JadwalObat>>(
      future: _futureListObat,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error); // Log error untuk debugging
          return const Center(
            child: Text('Gagal memuat data obat. Cek konsol.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada jadwal obat yang aktif hari ini.'),
          );
        }

        List<JadwalObat> listObat = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listObat.length,
          itemBuilder: (context, index) {
            return ObatItem(obat: listObat[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pastikan background halaman putih
      // --- App Bar Kustom ---
      appBar: AppBar(
        title: const Text(
          'Jadwal',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,

        // Leading Icon (Panah Kembali)
        leading: IconButton(
          // Ganti warna panah menjadi ORANYE
          icon: const Icon(
            Icons.arrow_back,
            color: _orangeAksen, // DIUBAH MENJADI _orangeAksen
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        // Actions (Icon Bantuan dan Download)
        actions: [
          // Icon Bantuan (Warna Biru Gelap)
          Padding(
            padding: const EdgeInsets.only(right: 4.0), // Jarak antar ikon
            child: Container(
              width: _kIconButtonSize,
              height: _kIconButtonSize,
              decoration: const BoxDecoration(
                color: _biruGelapIcon, // Warna biru gelap
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 16, // Ukuran ikon diperkecil
                ),
                onPressed: () {
                  print('Bantuan ditekan');
                },
              ),
            ),
          ),

          // Icon Download (Warna Orange)
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Jarak ke tepi kanan
            child: Container(
              width: _kIconButtonSize,
              height: _kIconButtonSize,
              decoration: const BoxDecoration(
                color: _orangeAksen, // Warna orange
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 16, // Ukuran ikon diperkecil
                ),
                onPressed: () {
                  print('Download ditekan');
                },
              ),
            ),
          ),
        ],

        // Garis Bawah (Bottom Border) - DITAMBAHKAN KEMBALI
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Tinggi garis
          child: Container(
            color: Colors.grey[300], // Warna garis abu-abu terang
            height: 1.0,
          ),
        ),
      ),

      // --- Body ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Search Bar ---
            // ... (Tidak Berubah)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100], // Abu-abu yang lebih terang
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Icon Filter
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _orangeAksen, // Warna Orange
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildCheckUpCard(),
            const SizedBox(height: 30),

            // --- Tinjauan Obat Harian Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tinjauan Obat Harian',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                // Tombol Tambah (FloatingActionButton)
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SajadTambahPage(),
                      ),
                    );
                  },
                  backgroundColor: _orangeAksen, // Warna Orange
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 15),
            _buildDailyMedicationList(),
          ],
        ),
      ),
    );
  }
}
