import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/main-features/welcome-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Default loading state
  String _userName = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Mengambil data dari tabel 'profiles' berdasarkan user ID
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single();

        // Update UI jika data ditemukan
        if (mounted && data['full_name'] != null) {
          setState(() {
            _userName = data['full_name'];
          });
        } else {
           // Fallback jika nama kosong di database
           setState(() {
            _userName = 'Pengguna';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _userName = 'Pengguna'; // Fallback jika error
        });
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SahabatRS"),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.waving_hand, size: 60, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Selamat Datang,",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF5966B1)
              ),
            ),
            const SizedBox(height: 10),
            const Text("Ini adalah halaman utama."),
          ],
        ),
      ),
    );
  }
}