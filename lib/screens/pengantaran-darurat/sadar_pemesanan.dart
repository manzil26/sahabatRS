import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SadarPemesan extends StatefulWidget {
  const SadarPemesan({super.key});

  @override
  State<SadarPemesan> createState() => _SadarPemesanState();
}

class _SadarPemesanState extends State<SadarPemesan> {
  final LatLng _center = LatLng(-7.2756, 112.6426);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sahabat_rs",
              ),
            ],
          ),

          /// TOMBOL BACK — SAMAA PERSIS SAMA SADAR MENCARI LOKASI
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/halaman-user");
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 28),
              ),
            ),
          ),

          /// BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 240,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  /// Icon tengah (tanpa gambar)
                  const Icon(
                    Icons.favorite,
                    color: Colors.orange,
                    size: 40,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Tenang dulu ya, Kami lagi nyari pendamping darurat secepatnya",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, "/halaman-user");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Batalkan Pesanan"),
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
