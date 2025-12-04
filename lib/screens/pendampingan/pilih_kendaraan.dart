import 'package:flutter/material.dart';

class PilihKendaraanPage extends StatelessWidget {
  const PilihKendaraanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- APP BAR (HEADER) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Biar flat tidak ada bayangan default
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange), // Panah Oranye
          onPressed: () {
            Navigator.pop(context); // Fungsi kembali
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
            icon: const Icon(Icons.help, color: Colors.indigo), // Icon tanya biru tua
            onPressed: () {},
          )
        ],
        // Garis tipis di bawah AppBar
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
            const SizedBox(height: 20), // Jarak dari atas
            
            // KARTU 1: MOBIL
            _buildVehicleCard(
              title: "Mobil",
              imagePath: "assets/images/mobil.png", // GANTI dengan path gambarmu
              bgColor: const Color(0xFF7986CB), // Warna Ungu Soft (Indigo 300)
              textColor: Colors.white,
              onTap: () {
                print("Pilih Mobil");
                // Masukkan logika navigasi di sini
              },
            ),

            const SizedBox(height: 24), // Jarak antar kartu

            // KARTU 2: MOTOR
            _buildVehicleCard(
              title: "Sepeda Motor",
              imagePath: "assets/images/motor.png", // GANTI dengan path gambarmu
              bgColor: const Color(0xFFFDD835), // Warna Kuning (Yellow 600)
              textColor: Colors.brown[800]!, // Teks warna coklat tua biar kebaca
              onTap: () {
                print("Pilih Motor");
                // Masukkan logika navigasi di sini
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TAMBAHAN (Biar kodingan di atas gak ruwet) ---
  // Ini fungsinya mirip component di Figma, jadi kita buat sekali, bisa dipanggil berkali-kali
  Widget _buildVehicleCard({
    required String title,
    required String imagePath,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Biar efek klik ngikutin bentuk bulat
      child: Container(
        width: double.infinity, // Lebar mentok kanan kiri
        height: 180, // Tinggi kartu
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), // Sudut melengkung
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4), // Posisi bayangan ke bawah
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar Kendaraan
            // PENTING: Pastikan gambar sudah didaftarkan di pubspec.yaml
            Image.asset(
              imagePath,
              height: 90, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Ini muncul kalau gambarmu belum ada/error
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