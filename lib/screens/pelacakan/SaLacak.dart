import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahabat_rs/models/keluarga.dart';
import 'package:sahabat_rs/services/salacak_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// HALAMAN SaLacak (Map + Tambahkan Orang Terdekat + Hubungkan)
/// - Muncul ketika:
///   1. Tombol "Pelacakan" di halaman-user.dart
///   2. Tombol "Keluarga" di profile.dart
class SaLacakPage extends StatefulWidget {
  const SaLacakPage({super.key});

  @override
  State<SaLacakPage> createState() => _SaLacakPageState();
}

class _SaLacakPageState extends State<SaLacakPage> {
  late Future<List<Keluarga>> _keluargaFuture;
  final Set<int> _selectedKeluargaIds = {}; // dipakai saat user pilih avatar

  @override
  void initState() {
    super.initState();
    _keluargaFuture = SaLacakService.getKeluargaSaya();
  }

  void _refreshKeluarga() {
    setState(() {
      _keluargaFuture = SaLacakService.getKeluargaSaya();
    });
  }

  // Dialog / bottom sheet untuk tambah orang terdekat
  void _showTambahKeluargaSheet() {
    final namaController = TextEditingController();
    final teleponController = TextEditingController();
    final hubunganController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Orang Terdekat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama lengkap",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Nomor telepon",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hubunganController,
                decoration: const InputDecoration(
                  labelText: "Hubungan (mis. Ibu, Suami)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (namaController.text.isEmpty ||
                        teleponController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama dan nomor telepon wajib diisi"),
                        ),
                      );
                      return;
                    }

                    await SaLacakService.tambahKeluarga(
                      nama: namaController.text,
                      nomorTelepon: teleponController.text,
                      hubungan: hubunganController.text.isEmpty
                          ? null
                          : hubunganController.text,
                    );

                    if (mounted) {
                      Navigator.of(ctx).pop();
                      _refreshKeluarga();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Orang terdekat berhasil ditambahkan"),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _onHubungkanPressed() {
    if (_selectedKeluargaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih minimal satu orang terdekat terlebih dahulu"),
        ),
      );
      return;
    }

    // Di sini nanti bisa disambungkan dengan logika 'share code' / notifikasi
    final waktu = DateFormat('dd MMM yyyy HH:mm', 'id_ID')
        .format(DateTime.now());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Berhasil menghubungkan ${_selectedKeluargaIds.length} orang "
          "terdekat pada $waktu",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background map + bottom card mirip desain Figma
      body: Stack(
        children: [
// BAGIAN MAP: OSM via flutter_map
Positioned.fill(
  child: FlutterMap(
    options: const MapOptions(
      // contoh: area ITS, silakan sesuaikan dengan yang kamu pakai di pengantaran-darurat
      initialCenter: LatLng(-7.2797, 112.7950),
      initialZoom: 15,
    ),
    children: [
      // LAYER TILE OSM
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.sahabat_rs',
      ),
    ],
  ),
),

          // Tombol back bulat di pojok kiri atas
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      // Pop saja → kalau datang dari profile akan balik ke profile
                      // kalau dari halaman-user akan balik ke halaman-user
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ),

          // BOTTOM SHEET "Tambahkan Orang Terdekat Anda"
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  // scroll tipis kalau tinggi layar kecil, supaya tidak overflow
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tambahkan Orang Terdekat Anda",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: FutureBuilder<List<Keluarga>>(
                          future: _keluargaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final keluargaList = snapshot.data ?? [];

                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Tombol "+"
                                GestureDetector(
                                  onTap: _showTambahKeluargaSheet,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7986CB),
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            const Icon(Icons.add_rounded),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Tambah",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Daftar avatar orang terdekat dari DB
                                ...keluargaList.map((k) {
                                  final selected = _selectedKeluargaIds
                                      .contains(k.idKeluarga);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selected) {
                                          _selectedKeluargaIds
                                              .remove(k.idKeluarga);
                                        } else {
                                          _selectedKeluargaIds
                                              .add(k.idKeluarga);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _KeluargaAvatar(
                                        nama: k.namaLengkap,
                                        selected: selected,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(
                                  color: Color(0xFFBDC3C7),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("Batal"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onHubungkanPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "Hubungkan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7986CB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.ios_share_rounded,
                              size: 18,
                              color: Color.fromARGB(221, 255, 255, 255),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Bagikan kode dengan...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget avatar kecil mirip desain Figma (lingkaran foto + titik kuning)
class _KeluargaAvatar extends StatelessWidget {
  final String nama;
  final bool selected;

  const _KeluargaAvatar({
    required this.nama,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC63A),
                    Color(0xFFFF8A45),
                  ],
                ),
                border: Border.all(
                  color: selected ? Colors.orange : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  inisial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Titik kuning kecil di kanan bawah
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC63A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
