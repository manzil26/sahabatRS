import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'sadar_rating.dart';
import 'sadar_konfirmasi.dart'; // untuk tombol back

class SadarPengantaranSelesai extends StatelessWidget {
  const SadarPengantaranSelesai({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// ================== MAP ==================
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-7.2756, 112.6426),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sahabat_rs",
              ),
            ],
          ),

          /// ================== BACK BUTTON ==================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SadarKonfirmasi(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          /// ================== BOTTOM SHEET ==================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/driver.png"),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Esa Anugrah",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Ambulance"),

                  const Spacer(),

                  /// ========== BUTTON "Pengantaran Selesai" ==========
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SadarRating(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Pengantaran Selesai",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
