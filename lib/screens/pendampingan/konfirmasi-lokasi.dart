import 'dart:math'; // Buat Random
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../pembayaran/pembayaran-digital.dart'; // Pastikan path benar

class KonfirmasiLokasiPage extends StatelessWidget {
  final String namaJemput;
  final String namaTujuan;

  KonfirmasiLokasiPage({
    super.key,
    required this.namaJemput,
    required this.namaTujuan,
  });

  final LatLng titikJemput = const LatLng(-7.291771, 112.793264); 
  final LatLng titikTujuan = const LatLng(-7.282356, 112.794925); 

  // DAFTAR NAMA DRIVER (DUMMY BIAR VARIATIF)
  final List<String> _listDriver = [
    "Budi Santoso",
    "Agus Setiawan",
    "Rudi Hartono",
    "Siti Aminah",
    "Joko Anwar",
    "Eko Prasetyo"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PETA (Background)
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
                    color: Colors.blue.withOpacity(0.6),
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

          // Tombol Back
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // CARD BAWAH
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
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.location_on, Colors.orange, namaJemput),
                        const Divider(height: 16),
                        _buildInfoRow(Icons.local_hospital, Colors.indigo, namaTujuan),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // TOMBOL PESAN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // 1. ACAK HARGA (Antara 15rb - 50rb)
                        int randomHarga = (Random().nextInt(35) + 15) * 1000;
                        
                        // 2. ACAK DRIVER (Ambil satu dari list)
                        String randomDriver = _listDriver[Random().nextInt(_listDriver.length)];

                        // 3. LEMPAR DATA KE PEMBAYARAN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PembayaranDigitalPage(
                              namaDriver: randomDriver,  // Nama driver beda-beda
                              hargaTransport: randomHarga, // Harga beda-beda
                            ),
                          ),
                        );
                      },
                      child: const Text("Pesan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.isEmpty ? "-" : text, 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}