import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/auth/login-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Tambahkan GlobalKey untuk validasi form
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _keepLoggedIn = false;

  final supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    // 1. Jalankan Validasi Form
    if (!_formKey.currentState!.validate()) {
      return; // Berhenti jika tidak valid
    }

    setState(() => _isLoading = true);
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text, // Simpan nama di metadata agar mudah diambil
        },
      );
      
      // Jika Trigger Database kamu sudah aktif, tabel profiles akan terisi otomatis.
      // Jika BELUM, kamu bisa uncomment kode di bawah ini:
      /*
      if (res.user != null) {
         await supabase.from('profiles').insert({
          'id': res.user!.id,
          'full_name': _nameController.text,
          'role': 'pasien',
        });
      }
      */

      if (mounted) {
        // Cek apakah user perlu konfirmasi email (Supabase default)
        if (res.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Daftar berhasil! Cek email untuk verifikasi.")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Jika auto-confirm aktif, langsung masuk
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Akun berhasil dibuat!")),
          );
          // Arahkan ke rute '/' yang sekarang akan mendeteksi session dan ke Home
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6A230), Color(0xFFFFFFFF), Color(0xFF5966B1)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // Bungkus Column dengan Form
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daftar",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Input Nama dengan Validasi
                    _buildInput(
                      "Nama", 
                      _nameController, 
                      'assets/icons/ic_user.png', 
                      false,
                      (value) {
                        if (value == null || value.length < 3) {
                          return 'Nama minimal 3 huruf';
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 15),

                    // Input Email dengan Validasi
                    _buildInput(
                      "Email", 
                      _emailController, 
                      'assets/icons/ic_email.png', 
                      false,
                      (value) {
                        if (value == null || !value.contains('@') || !value.contains('.')) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 15),

                    // Input Sandi dengan Validasi
                    _buildInput(
                      "Sandi", 
                      _passwordController, 
                      'assets/icons/ic_lock.png', 
                      true,
                      (value) {
                        if (value == null || value.length < 8) {
                          return 'Sandi minimal 8 karakter';
                        }
                        return null;
                      }
                    ),
                    
                    // ... (Checkbox dan tombol sama seperti sebelumnya)
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _keepLoggedIn,
                          onChanged: (val) {
                            setState(() => _keepLoggedIn = val!);
                          },
                        ),
                        const Text("Simpan akun", style: TextStyle(color: Color(0xFF5966B1))),
                      ],
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6A230),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Buat Akun", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    // ... (Sisa tombol google dan login link sama seperti sebelumnya)
                    const SizedBox(height: 15),
                    const Center(child: Text("atau", style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 15),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/ic_google.png', height: 24, errorBuilder: (_,__,___) => const Icon(Icons.g_mobiledata)),
                            const SizedBox(width: 10),
                            const Text("Daftar dengan Google", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah memiliki akun? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          },
                          child: const Text("Masuk", style: TextStyle(color: Color(0xFF5966B1), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Input yang diperbarui dengan Validator
  Widget _buildInput(
    String hint, 
    TextEditingController controller, 
    String iconPath, 
    bool isPassword,
    String? Function(String?)? validator, // Parameter validator baru
  ) {
    return TextFormField( // Gunakan TextFormField, bukan TextField
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      validator: validator, // Pasang validator
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validasi saat mengetik
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconPath, width: 20, height: 20, errorBuilder: (_,__,___) => const Icon(Icons.error)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}