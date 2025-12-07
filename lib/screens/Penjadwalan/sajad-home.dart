import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import halaman-halaman terkait
import 'sajad-tambah.dart';
import 'jadwal.dart';
import 'sajad-edit.dart';

// Import Model & Service (PATH DIPERBAIKI)
import '../../models/jadwal_obat.dart';
import '../../models/jadwal_checkup_detail.dart';
import '../../services/jadwal_service.dart';

// --- Kode Warna Khusus ---
const Color _kuningCheckUp = Color(0xFFFCDD7A);
const Color _orangeAksen = Color(0xFFF6A230);
const Color _biruGelapIcon = Color(0xFF5966B1);
const double _kIconButtonSize = 30.0;

// --- Widget Kustom untuk Item Obat ---
class ObatItem extends StatelessWidget {
  final JadwalObat obat;
  final VoidCallback? onEdit;

  const ObatItem({Key? key, required this.obat, this.onEdit}) : super(key: key);

  String getStatusText(bool isSelesai, TimeOfDay jam) {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      jam.hour,
      jam.minute,
    );

    if (now.isAfter(scheduledTime)) {
      return 'Selesai'; // Logika sederhana, bisa disesuaikan
    }
    return 'Belum Dimulai';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Belum Dimulai':
        return const Color.fromARGB(255, 39, 94, 215);
      default:
        return Colors.grey;
    }
  }

  Widget getObatIconWidget() {
    // Pastikan aset ini ada, jika tidak, gunakan Icon sebagai fallback
    return Image.asset(
      'assets/images/penjadwalan/pil.png',
      width: 24,
      height: 24,
      color: Colors.grey[600],
      errorBuilder: (context, error, stackTrace) => Icon(Icons.medication, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = obat.jamMinum.format(context);
    final statusText = getStatusText(obat.statusSelesai, obat.jamMinum);
    final statusColor = getStatusColor(statusText);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: const Color(0xFFF8F8F6),
        borderRadius: BorderRadius.circular(15),
        elevation: 1,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SajadEditPage(obat: obat),
              ),
            ).then((_) {
              if (onEdit != null) {
                onEdit!();
              }
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                getObatIconWidget(),
                const SizedBox(width: 15),
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
                            '• $statusText',
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

// --- Halaman Utama Sajad Home ---
class SajadHomePage extends StatefulWidget {
  const SajadHomePage({Key? key}) : super(key: key);

  @override
  State<SajadHomePage> createState() => _SajadHomePageState();
}

class _SajadHomePageState extends State<SajadHomePage> {
  late Future<JadwalCheckUpDetail?> _futureJadwalCheckUp;
  late Future<List<JadwalObat>> _futureListObat;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _futureJadwalCheckUp = JadwalService.getNextJadwalCheckUpDetail();
    _futureListObat = JadwalService.getTinjauanObatHarian();
  }

  void _refreshData() {
    setState(() {
      _fetchData();
    });
  }

  Widget _buildCheckUpCard() {
    return FutureBuilder<JadwalCheckUpDetail?>(
      future: _futureJadwalCheckUp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LinearProgressIndicator(
              color: _kuningCheckUp,
              backgroundColor: const Color(0xFFFCDD7A).withOpacity(0.3),
            ),
          );
        }

        JadwalCheckUpDetail? detail = snapshot.data;

        String tanggalCheckUp = detail != null
            ? DateFormat('dd MMMM yyyy').format(detail.tanggal)
            : 'Belum ada jadwal';

        String infoKegiatan = detail != null
            ? '${detail.kegiatan} di ${detail.lokasi}'
            : 'Selanjutnya pada';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kuningCheckUp,
            borderRadius: BorderRadius.circular(20),
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
                      infoKegiatan,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      tanggalCheckUp,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JadwalPage(),
                          ),
                        ).then((_) => _refreshData());
                      },
                      child: const Text(
                        'Selengkapnya',
                        style: TextStyle(
                          color: _biruGelapIcon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Image placeholder jika tidak ada asset
              Image.asset(
                'assets/images/penjadwalan/notes.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.note_alt, size: 80, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyMedicationList() {
    return FutureBuilder<List<JadwalObat>>(
      future: _futureListObat,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
            return ObatItem(
              obat: listObat[index],
              onEdit: _refreshData,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _orangeAksen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.download, color: _orangeAksen),
              onPressed: () {},
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCDD7A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCheckUpCard(),
            const SizedBox(height: 30),
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
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SajadTambahPage(),
                      ),
                    ).then((_) => _refreshData());
                  },
                  backgroundColor: const Color(0xFFFC770F),
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