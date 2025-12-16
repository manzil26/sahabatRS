import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// PENTING: Import halaman rating
import 'rating.dart'; 

class PengantaranSelesaiPage extends StatelessWidget {
  final String namaDriver;

  const PengantaranSelesaiPage({super.key, required this.namaDriver});

  @override
  Widget build(BuildContext context) {
    // Koordinat Tujuan (RS)
    final LatLng titikTujuan = const LatLng(-7.282356, 112.794925); 

    return Scaffold(
      body: Stack(
        children: [
          // --- LAYER 1: PETA ---
          FlutterMap(
            options: MapOptions(
              initialCenter: titikTujuan, 
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: titikTujuan,
                    width: 80, height: 80,
                    child: const Icon(Icons.location_on, color: Colors.indigo, size: 50),
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
                    // Kalau back ditekan, kembali ke beranda
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
          ),

          // --- LAYER 3: KARTU SELESAI ---
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

                  // Avatar Driver
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue[50],
                    child: const Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    namaDriver, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ambulance", 
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // TOMBOL PENGANTARAN SELESAI
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      // --- DISINI PERUBAHANNYA ---
                      onPressed: () {
                        // Pindah ke Halaman Rating
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatingPage(namaDriver: namaDriver),
                          ),
                        );
                      },
                      child: const Text(
                        "Pengantaran Selesai",
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