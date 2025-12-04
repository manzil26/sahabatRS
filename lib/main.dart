import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/auth/login-page.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart'; // Pastikan import ini benar
import 'package:sahabat_rs/screens/main-features/welcome-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN 1: PANGGIL FILE HALAMAN KAMU ---
// Pastikan nama file di folder screens/pendampingan sudah 'pilih_kendaraan.dart'
import 'screens/pendampingan/pilih_kendaraan.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- BAGIAN 2: KONEKSI DATABASE (JANGAN DIUBAH) ---
  await Supabase.initialize(
    url: "https://ppvjjumolctwzrednvul.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwdmpqdW1vbGN0d3pyZWRudnVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMjU3NDksImV4cCI6MjA3OTcwMTc0OX0.62vU78949hwLBnNzuPq_hrGMwPY5aH7jFRzRbmvIJJc",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SahabatRS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) {
          // CEK SESI DI SINI
          final session = Supabase.instance.client.auth.currentSession;
          
          // Jika session ada, ke HomePage. Jika tidak, ke WelcomePage.
          return session != null ? const HomePage() : const WelcomePage();
        },
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}