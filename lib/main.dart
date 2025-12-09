import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sahabat_rs/screens/auth/login-page.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart';
import 'package:sahabat_rs/screens/main-features/welcome-page.dart';
import 'package:sahabat_rs/screens/pelacakan/SaLacak.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/sadar_mencari_lokasi.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/sadar_konfirmasi.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/sadar_rating.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/sadar_pengantaran_selesai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

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
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      // Konfigurasi Lokalisasi (Bahasa)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris
      ],
      initialRoute: '/',
      routes: {
        '/': (context) {
          final session = Supabase.instance.client.auth.currentSession;
          // Cek sesi login
          return session != null ? const HalamanUser() : const WelcomePage();
        },
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HalamanUser(),
        '/salacak': (context) => const SaLacakPage(),

        // Pengantaran-darurat routes 
        '/lokasi': (context) => const SadarMencariLokasi(),
        '/konfirmasi': (context) => const SadarKonfirmasi(),
        '/rating': (context) => const SadarRating(),
        '/selesai': (context) => const SadarPengantaranSelesai(),
      },
    );
  }
}
