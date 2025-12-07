import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/Sadar-Pemesan.dart'; // Import halaman tujuan

class PilihKendaraanPage extends StatelessWidget {
  const PilihKendaraanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- APP BAR (HEADER) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange), 
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          "Pilih Kendaraan Pendamping",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help, color: Colors.indigo), 
            onPressed: () {},
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      
      // --- BODY (ISI HALAMAN) ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20), 
            
            // KARTU 1: MOBIL
            _buildVehicleCard(
              title: "Mobil",
              // Pastikan path gambar benar
              imagePath: "assets/images/mobil.png", 
              bgColor: const Color(0xFF7986CB), 
              textColor: Colors.white,
              onTap: () {
                // Navigasi ke SadarPemesan saat Mobil dipilih
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SadarPemesan()),
                );
              },
            ),

            const SizedBox(height: 24), 

            // KARTU 2: MOTOR
            _buildVehicleCard(
              title: "Sepeda Motor",
              // Pastikan path gambar benar
              imagePath: "assets/images/motor.png", 
              bgColor: const Color(0xFFFDD835), 
              textColor: Colors.brown[800]!, 
              onTap: () {
                // Navigasi ke SadarPemesan saat Motor dipilih
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SadarPemesan()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TAMBAHAN ---
  Widget _buildVehicleCard({
    required String title,
    required String imagePath,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity, 
        height: 180, 
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4), 
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar Kendaraan
            Image.asset(
              imagePath,
              height: 90, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.directions_car, size: 80, color: Colors.white54);
              },
            ),
            const SizedBox(height: 10),
            // Teks Judul
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}