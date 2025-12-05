import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// screens
import 'package:sahabat_rs/screens/auth/login-page.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart';
import 'package:sahabat_rs/screens/main-features/welcome-page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Koneksi Supabase (punyamu, tidak diubah)
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
      title: 'SahabatRS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          // cek sesi supabase
          final session = Supabase.instance.client.auth.currentSession;

          // kalau sudah login → langsung ke HalamanUser
          // kalau belum → ke WelcomePage
          return session != null ? HalamanUser() : WelcomePage();
        },

        // halaman login
        '/login': (context) => LoginPage(),

        // route home setelah login sukses
        '/home': (context) => HalamanUser(),
      },
    );
  }
}
