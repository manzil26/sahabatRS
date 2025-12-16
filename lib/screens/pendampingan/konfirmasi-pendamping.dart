import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'pengantaran-selesai.dart'; // Import halaman selanjutnya

class KonfirmasiPendampingPage extends StatefulWidget {
  final String namaDriver; 

  const KonfirmasiPendampingPage({super.key, required this.namaDriver});

  @override
  State<KonfirmasiPendampingPage> createState() => _KonfirmasiPendampingPageState();
}

class _KonfirmasiPendampingPageState extends State<KonfirmasiPendampingPage> with SingleTickerProviderStateMixin {
  
  // Koordinat
  final LatLng titikJemput = const LatLng(-7.291771, 112.793264);
  final LatLng titikTujuan = const LatLng(-7.282356, 112.794925);
  // Titik Awal Driver (Ceritanya driver ada di agak jauh dikit)
  final LatLng titikDriverStart = const LatLng(-7.295000, 112.790000); 

  late AnimationController _controller;
  late LatLng _posisiMobil;

  @override
  void initState() {
    super.initState();
    
    // Posisi awal mobil di start point driver
    _posisiMobil = titikDriverStart;

    // Total durasi 10 detik (5 detik jemput + 5 detik antar)
    _controller = AnimationController(
      duration: const Duration(seconds: 10), 
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        double t = _controller.value; // Nilai berjalan dari 0.0 sampai 1.0

        if (t <= 0.5) {
          // --- FASE 1 (0-5 Detik): Driver OTW ke Titik Jemput ---
          // Kita normalisasi t (0.0 - 0.5) menjadi localT (0.0 - 1.0)
          double localT = t * 2; 
          
          double lat = titikDriverStart.latitude + (titikJemput.latitude - titikDriverStart.latitude) * localT;
          double lng = titikDriverStart.longitude + (titikJemput.longitude - titikDriverStart.longitude) * localT;
          _posisiMobil = LatLng(lat, lng);

        } else {
          // --- FASE 2 (5-10 Detik): Dari Jemput OTW ke RS ---
          // Kita normalisasi t (0.5 - 1.0) menjadi localT (0.0 - 1.0)
          double localT = (t - 0.5) * 2;

          double lat = titikJemput.latitude + (titikTujuan.latitude - titikJemput.latitude) * localT;
          double lng = titikJemput.longitude + (titikTujuan.longitude - titikJemput.longitude) * localT;
          _posisiMobil = LatLng(lat, lng);
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animasi Selesai -> Pindah Halaman
        _pindahKeSelesai();
      }
    });

    // Mulai Jalan
    _controller.forward();
  }

  void _pindahKeSelesai() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PengantaranSelesaiPage(namaDriver: widget.namaDriver),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- LAYER 1: PETA ---
          FlutterMap(
            options: MapOptions(
              // Kamera diam di tengah-tengah area
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
                  // Garis Rute (Jemput ke Tujuan)
                  Polyline(
                    points: [titikJemput, titikTujuan],
                    strokeWidth: 5.0,
                    color: Colors.indigo,
                  ),
                  // Garis Driver ke Jemput (Opsional, biar kelihatan rute drivernya)
                  Polyline(
                    points: [titikDriverStart, titikJemput],
                    strokeWidth: 3.0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Marker Jemput
                  Marker(
                    point: titikJemput,
                    width: 60, height: 60,
                    child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
                  ),
                  // Marker Tujuan
                  Marker(
                    point: titikTujuan,
                    width: 60, height: 60,
                    child: const Icon(Icons.local_hospital, color: Colors.indigo, size: 40),
                  ),
                  
                  // MOBIL (Bergerak)
                  Marker(
                    point: _posisiMobil, 
                    width: 50, height: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                      ),
                      child: const Icon(Icons.directions_car, color: Colors.black, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- LAYER 2: TOMBOL BACK ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    _controller.stop();
                     Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
          ),

          // --- LAYER 3: KARTU DRIVER (Visual dikembalikan ke awal) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
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
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),

                  // Info Driver
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue[50],
                        child: const Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.namaDriver, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "B 1234 CCC", 
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      _buildCircleButton(Icons.call, Colors.indigo),
                      const SizedBox(width: 12),
                      _buildCircleButton(Icons.chat_bubble, Colors.indigo),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Status Chips (KEMBALI KE VISUAL AWAL: MOHON DITUNGGU)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: const [
                            Text("Mohon Ditunggu 🙏", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            CircleAvatar(radius: 8, backgroundColor: Colors.indigo, child: Text("1", style: TextStyle(fontSize: 10, color: Colors.white))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tombol Lacak (Tetap ada sesuai request)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                         // Tidak ada aksi khusus, cuma tombol display
                      },
                      child: const Text("Lacak Pendampingan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildCircleButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}