import 'package:flutter/material.dart';

// Import semua halaman
import 'screens/pengantaran-darurat/sadar_pemesanan.dart';
import 'screens/pengantaran-darurat/sadar_mencari_lokasi.dart';
import 'screens/pengantaran-darurat/sadar_konfirmasi.dart';
import 'screens/pengantaran-darurat/sadar_rating.dart';
import 'screens/pengantaran-darurat/sadar_pengantaran_selesai.dart';

void main() {
  runApp(const SahabatRS());
}

class SahabatRS extends StatelessWidget {
  const SahabatRS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SadarPengantaranSelesai(),


      routes: {
        '/pemesanan': (context) => const SadarPemesan(),
        "/lokasi": (context) => const SadarMencariLokasi(),

        /// 🔥 ROUTE BENAR (WAJIB)
        "/sadar-konfirmasi": (context) => const SadarKonfirmasi(),

        "/rating": (context) => const SadarRating(),
        "/selesai": (context) => const SadarPengantaranSelesai(),
      },
    );
  }
}
