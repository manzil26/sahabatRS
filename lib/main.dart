import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/edit-profile/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN 1: PANGGIL FILE HALAMAN KAMU ---
// Pastikan nama file di folder screens/pendampingan sudah 'pilih_kendaraan.dart'
import 'screens/pendampingan/pilih_kendaraan.dart'; 
import 'screens/edit-profile/edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- BAGIAN 2: KONEKSI DATABASE (JANGAN DIUBAH) ---
  await Supabase.initialize(
    url: "https://ppvjjumolctwzrednvul.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwdmpqdW1vbGN0d3pyZWRudnVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMjU3NDksImV4cCI6MjA3OTcwMTc0OX0.62vU78949hwLBnNzuPq_hrGMwPY5aH7jFRzRbmvIJJc",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Biar tulisan DEBUG di pojok kanan atas hilang
      title: 'Sahabat RS',
      theme: ThemeData(
        // Ini tema warna default aplikasi (bisa disesuaikan)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
          
  
      // --- BAGIAN 3: TENTUKAN HALAMAN PERTAMA ---
      // Di sini kita pasang halaman PilihKendaraanPage sebagai halaman utama yang muncul
      home: const EditProfilePage(), 
    );
  }
}