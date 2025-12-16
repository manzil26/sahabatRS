import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'set-lokasi.dart';        
import 'konfirmasi-lokasi.dart'; 

class JemputPage extends StatefulWidget {
  const JemputPage({super.key});

  @override
  State<JemputPage> createState() => _JemputPageState();
}

class _JemputPageState extends State<JemputPage> {
  final LatLng _center = const LatLng(-7.282356, 112.794925);
  
  final TextEditingController _jemputController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();

  // FUNGSI BARU: CEK & PINDAH OTOMATIS
  void _cekDanPindahOtomatis() {
    if (_jemputController.text.isNotEmpty && _tujuanController.text.isNotEmpty) {
      // Kasih jeda dikit biar user 'ngeh' teksnya udah masuk, baru pindah
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KonfirmasiLokasiPage(
              namaJemput: _jemputController.text,
              namaTujuan: _tujuanController.text,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // MAP BACKGROUND
          FlutterMap(
            options: MapOptions(initialCenter: _center, initialZoom: 15.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 80, height: 80,
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // BACK BUTTON
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

          // FORM INPUT
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // INPUT JEMPUT
                        TextField(
                          controller: _jemputController,
                          readOnly: true, 
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SetLokasiPage(isJemput: true)),
                            );
                            if (result != null) {
                              setState(() => _jemputController.text = result);
                              _cekDanPindahOtomatis(); // <--- CEK OTOMATIS DISINI
                            }
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.location_on, color: Colors.orange),
                            hintText: "Pilih titik jemput",
                            border: InputBorder.none,
                          ),
                        ),
                        
                        const Divider(height: 1),
                        
                        // INPUT TUJUAN
                        TextField(
                          controller: _tujuanController,
                          readOnly: true, 
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SetLokasiPage(isJemput: false)),
                            );
                            if (result != null) {
                              setState(() => _tujuanController.text = result);
                              _cekDanPindahOtomatis(); // <--- CEK OTOMATIS DISINI JUGA
                            }
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.local_hospital, color: Colors.indigo),
                            hintText: "Pilih rumah sakit tujuan",
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON PESAN (Masih ada, buat jaga-jaga kalau user mau klik manual)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                         _cekDanPindahOtomatis(); // Panggil fungsi yang sama
                      },
                      child: const Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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