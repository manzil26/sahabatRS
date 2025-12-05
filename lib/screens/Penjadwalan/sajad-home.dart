import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // DIHAPUS/DIKOMENTARI
// Pastikan import model dan service sudah benar
import '../../../../models/jadwal_obat.dart';
import '../../../../services/jadwal_service.dart';

// --- Widget Kustom untuk Item Obat ---
class ObatItem extends StatelessWidget {
  final JadwalObat obat;

  const ObatItem({Key? key, required this.obat}) : super(key: key);

  // Fungsi untuk menentukan teks status berdasarkan statusSelesai (boolean) dan waktu
  String getStatusText(bool isSelesai, TimeOfDay jam) {
    if (isSelesai) return 'Selesai';

    // Logika untuk menentukan 'Terlewat'
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      jam.hour,
      jam.minute,
    );

    // Jika waktu sekarang sudah melewati waktu minum
    if (now.isAfter(scheduledTime)) {
      return 'Terlewat';
    }
    return 'Belum Diminum';
  }

  // Fungsi untuk menentukan warna status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Terlewat':
        return Colors.red;
      case 'Skip':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memformat TimeOfDay menjadi String
    final formattedTime = obat.jamMinum.format(context);

    final statusText = getStatusText(obat.statusSelesai, obat.jamMinum);
    final statusColor = getStatusColor(statusText);

    return InkWell(
      onTap: () {
        print('Detail ${obat.namaObat}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Icon Obat
            const Icon(Icons.medical_services_outlined, color: Colors.blueGrey),
            const SizedBox(width: 15),
            // Nama Obat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obat.namaObat,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Waktu dan Status
                  Row(
                    children: [
                      Text(
                        '$formattedTime • ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Panah (>)
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- Halaman Utama Sajad Home ---
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
    _futureJadwalCheckUp = JadwalService.getJadwalCheckUp();
    _futureListObat = JadwalService.getTinjauanObatHarian();
  }

  // Widget Builder untuk Jadwal Check-Up
  Widget _buildCheckUpCard() {
    return FutureBuilder<DateTime?>(
      future: _futureJadwalCheckUp,
      builder: (context, snapshot) {
        // Tampilkan Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LinearProgressIndicator(color: Colors.orange[400]),
          );
        }

        // Ambil Data
        DateTime? jadwal = snapshot.data;
        String formattedDate = jadwal != null
            ? DateFormat('dd MMMM yyyy').format(jadwal)
            : 'Belum ada jadwal';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jadwal Check-Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selanjutnya pada\n$formattedDate',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
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
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                // --- PERBAIKAN PENTING DI SINI: Menggunakan Image.asset untuk PNG ---
                child: Image.asset(
                  'assets/images/penjadwalan/notes.png', // PATH ke file PNG Anda
                  width: 70,
                  height: 70,
                  // CATATAN: properti colorFilter telah DIHAPUS
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget Builder untuk Daftar Obat Harian
  Widget _buildDailyMedicationList() {
    return FutureBuilder<List<JadwalObat>>(
      future: _futureListObat,
      builder: (context, snapshot) {
        // Tampilkan Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Tampilkan Error
        if (snapshot.hasError) {
          print(snapshot.error); // Log error untuk debugging
          return Center(child: Text('Gagal memuat data obat. Cek konsol.'));
        }

        // Tampilkan Data Kosong
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada jadwal obat yang aktif hari ini.'),
          );
        }

        // Tampilkan Daftar
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
      // App Bar Kustom
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Jadwal'),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Search Bar ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
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
                    color: Colors.orange[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Jadwal Check-Up Card (Menggunakan FutureBuilder) ---
            _buildCheckUpCard(),

            const SizedBox(height: 30),

            // --- Tinjauan Obat Harian Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tinjauan Obat Harian',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    print('Tambah Jadwal Obat');
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --- Daftar Obat Harian (Menggunakan FutureBuilder) ---
            _buildDailyMedicationList(),
          ],
        ),
      ),
    );
  }
}
