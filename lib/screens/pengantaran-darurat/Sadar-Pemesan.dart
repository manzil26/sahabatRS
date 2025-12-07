import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/saDar-mencari-lokasi.dart';

class SadarPemesan extends StatefulWidget {
  const SadarPemesan({super.key});

  @override
  State<SadarPemesan> createState() => _SadarPemesanState();
}

class _SadarPemesanState extends State<SadarPemesan> {
  @override
  void initState() {
    super.initState();
    // Simulasi delay otomatis pindah ke halaman berikutnya setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SadarMencariLokasi()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAP BACKGROUND
          Container(color: Colors.grey.shade300),

          // BOTTOM PANEL
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.health_and_safety,
                            color: Colors.orange, size: 40),
                        SizedBox(height: 10),
                        Text(
                          "Tenang dulu ya, Kami lagi nyari pendamping darurat secepatnya",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        CircularProgressIndicator(color: Colors.orange), // Tambahan indikator
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: const Text("Batalkan Pesanan", style: TextStyle(color: Colors.white)),
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