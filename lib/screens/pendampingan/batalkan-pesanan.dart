import 'dart:async'; // Buat Timer
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// Import halaman selanjutnya (Driver Ketemu)
import 'konfirmasi-pendamping.dart'; 

class BatalkanPesananPage extends StatefulWidget {
  final String namaDriver; 

  const BatalkanPesananPage({super.key, required this.namaDriver});

  @override
  State<BatalkanPesananPage> createState() => _BatalkanPesananPageState();
}

class _BatalkanPesananPageState extends State<BatalkanPesananPage> {
  Timer? _timer;

  // Koordinat Demo (Sama kayak sebelumnya biar map-nya gak berubah)
  final LatLng titikJemput = const LatLng(-7.291771, 112.793264);
  final LatLng titikTujuan = const LatLng(-7.282356, 112.794925);

  @override
  void initState() {
    super.initState();
    // --- TIMER 5 DETIK ---
    // Kalau user diam aja selama 5 detik, otomatis dapat driver
    _timer = Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => KonfirmasiPendampingPage(namaDriver: widget.namaDriver),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Matikan timer kalau keluar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- LAYER 1: PETA (Background) ---
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                (titikJemput.latitude + titikTujuan.latitude) / 2,
                (titikJemput.longitude + titikTujuan.longitude) / 2,
              ),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [titikJemput, titikTujuan],
                    strokeWidth: 5.0,
                    color: Colors.indigo,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: titikJemput,
                    width: 60, height: 60,
                    child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
                  ),
                  Marker(
                    point: titikTujuan,
                    width: 60, height: 60,
                    child: const Icon(Icons.local_hospital, color: Colors.indigo, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // --- LAYER 2: TOMBOL BACK (Kiri Atas) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          // --- LAYER 3: KARTU "MENCARI..." (Bawah) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Hati / People
                  const Icon(Icons.diversity_1, size: 60, color: Colors.orange),
                  const SizedBox(height: 16),

                  // Teks
                  const Text(
                    "Tenang dulu ya,",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Kami lagi nyari pendamping untuk kamu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 24),

                  // Loading Indicator (Muter-muter)
                  const SizedBox(
                    height: 30, width: 30,
                    child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 3),
                  ),
                  
                  const SizedBox(height: 24),

                  // TOMBOL BATALKAN PESANAN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0), // Indigo/Ungu
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // LOGIKA BATALKAN
                        _timer?.cancel(); // 1. Stop Timer
                        
                        // 2. Balik ke Halaman Paling Awal (Jemput/Home)
                        // popUntil((route) => route.isFirst) akan menutup semua tumpukan halaman
                        // sampai menyisakan halaman pertama (Peta Awal).
                        Navigator.of(context).popUntil((route) => route.isFirst);

                        // 3. Notifikasi
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pesanan dibatalkan")),
                        );
                      },
                      child: const Text(
                        "Batalkan Pesanan",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}