// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 👇 TAMBAH BARIS INI 👇
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi locale data
// 👆 TAMBAH BARIS INI 👆

// Sesuaikan import path di bawah ini!
import 'package:sahabat_rs/screens/penjadwalan/sajad-home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INISIALISASI LOCALE DATA (PERBAIKAN ERROR) ---
  // Panggil fungsi inisialisasi untuk bahasa Indonesia (id_ID)
  await initializeDateFormatting('id_ID', null);
  // --- END INISIALISASI LOCALE DATA ---

  // --- INISIALISASI SUPABASE ---
  await Supabase.initialize(
    url: "https://ppvjjumolctwzrednvul.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwdmpqdW1vbGN0d3pyZWRudnVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMjU3NDksImV4cCI6MjA3OTcwMTc0OX0.62vU78949hwLBnNzuPq_hrGMwPY5aH7jFRzRbmvIJJc",
  );
  // --- END INISIALISASI SUPABASE ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAHABAT RS',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      // Pastikan menggunakan localizationsDelegates untuk mendukung bahasa Indonesia
      localizationsDelegates: const [
        // Tambahkan delegates jika menggunakan TableCalendar atau widget lain yang membutuhkan
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'), // Dukungan untuk bahasa Indonesia
      ],
      home: const SajadHomePage(),
    );
  }
}
