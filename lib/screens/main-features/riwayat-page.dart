import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sahabat_rs/screens/pendampingan/pilih_kendaraan.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  String _selectedTab = 'selesai'; // 'selesai' atau 'dibatalkan';
  late Future<List<_RiwayatItemData>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _futureRiwayat = _fetchRiwayat();
  }

  Future<List<_RiwayatItemData>> _fetchRiwayat() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      // belum login
      return [];
    }

    final data = await supabase
        .from('riwayatpesanan')
        .select(
          'id_riwayatpesanan, tanggal_waktu, nama_tempat, '
          'status_pendampingan, bisa_pesan_lagi, kategori_riwayat',
        )
        .eq('id_pengguna', user.id)
        .order('tanggal_waktu', ascending: false);

    return (data as List<dynamic>).map((row) {
      final map = row as Map<String, dynamic>;

      final tanggalRaw = map['tanggal_waktu'] as String?;
      DateTime? tanggalDt;
      if (tanggalRaw != null) {
        tanggalDt = DateTime.parse(tanggalRaw);
      }

      final String tanggalFormatted = tanggalDt != null
          ? DateFormat('d MMM, HH:mm').format(tanggalDt)
          : '-';

      final String namaTempat = (map['nama_tempat'] as String?) ?? '-';

      final String statusEnum =
          (map['status_pendampingan'] as String?) ?? 'selesai';

      // mapping enum -> text untuk di UI
      String statusText;
      switch (statusEnum) {
        case 'selesai':
          statusText = 'Pendampingan Selesai';
          break;
        case 'dibatalkan':
          statusText = 'Pendampingan Dibatalkan';
          break;
        case 'diminta':
          statusText = 'Permintaan Diproses';
          break;
        case 'dijemput':
          statusText = 'Pendamping Sedang Dijemput';
          break;
        case 'di_rs':
          statusText = 'Pendampingan Berlangsung';
          break;
        default:
          statusText = 'Status Tidak Diketahui';
      }

      final bool isDibatalkan = statusEnum == 'dibatalkan';

      return _RiwayatItemData(
        tanggal: tanggalFormatted,
        namaRs: namaTempat,
        status: statusText,
        isDibatalkan: isDibatalkan,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: const [
          Icon(Icons.help_outline, color: Color(0xFF6C7A89)),
          SizedBox(width: 8),
          Icon(Icons.download_rounded, color: Color(0xFF6C7A89)),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Segmented tab Selesai / Dibatalkan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F6),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _SegmentTab(
                    label: 'Selesai',
                    selected: _selectedTab == 'selesai',
                    onTap: () {
                      setState(() {
                        _selectedTab = 'selesai';
                      });
                    },
                  ),
                  _SegmentTab(
                    label: 'Dibatalkan',
                    selected: _selectedTab == 'dibatalkan',
                    onTap: () {
                      setState(() {
                        _selectedTab = 'dibatalkan';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // LIST RIWAYAT
          Expanded(
            child: FutureBuilder<List<_RiwayatItemData>>(
              future: _futureRiwayat,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat riwayat.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }

                var list = snapshot.data ?? [];

                // filter sesuai tab
                if (_selectedTab == 'selesai') {
                  list = list.where((e) => !e.isDibatalkan).toList();
                } else {
                  list = list.where((e) => e.isDibatalkan).toList();
                }

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat pendampingan.',
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _RiwayatCard(item: list[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====== MODEL DATA UNTUK UI ======

class _RiwayatItemData {
  final String tanggal;
  final String namaRs;
  final String status;
  final bool isDibatalkan;

  const _RiwayatItemData({
    required this.tanggal,
    required this.namaRs,
    required this.status,
    required this.isDibatalkan,
  });
}

// ====== WIDGET KARTU RIWAYAT ======

class _RiwayatCard extends StatelessWidget {
  final _RiwayatItemData item;

  const _RiwayatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        item.isDibatalkan ? const Color(0xFFE74C3C) : const Color(0xFF27AE60);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon RS/kendaraan (sementara icon default)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD56B),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_hospital, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tanggal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF95A5A6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.namaRs,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      item.isDibatalkan
                          ? Icons.cancel_rounded
                          : Icons.check_circle_rounded,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PilihKendaraanPage(),
              ),
            );
            },
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Pesan Lagi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== SEGMENT TAB ======

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SegmentTab({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF2C3E50)
                  : const Color(0xFF7F8C8D),
            ),
          ),
        ),
      ),
    );
  }
}
