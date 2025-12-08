import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SadarPengantaranSelesai extends StatelessWidget {
  const SadarPengantaranSelesai({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-7.2756, 112.6426),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sahabat_rs",
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/driver.png"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Esa Anugrah",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Ambulance"),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text("Pengantaran Selesai"),
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
