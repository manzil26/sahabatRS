import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/auth/login-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _keepLoggedIn = false;

  final supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() => _isLoading = true);
    try {
      // 1. Daftar ke Auth Supabase (Email & Password)
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {
          'name': _nameController.text, // Simpan nama di metadata juga
        },
      );

      // 2. Simpan detail ke tabel 'pengguna' (Sesuai ERD)
      if (res.user != null) {
        await supabase.from('pengguna').insert({
          'id_pengguna': res.user!.id, // PK: id_pengguna = UID Auth
          'name': _nameController.text,
          'email': _emailController.text,
          // Field lain dari ERD bisa diisi default atau null dulu
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          if (res.session == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Daftar berhasil! Cek email untuk verifikasi.")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Akun berhasil dibuat!")),
            );
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
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

                    // Input Nama
                    _buildInput(
                      "Nama", 
                      _nameController, 
                      'assets/icons/ic_user.png', 
                      false,
                      (value) => (value == null || value.length < 3) ? 'Nama minimal 3 huruf' : null
                    ),
                    const SizedBox(height: 15),

                    // Input Email
                    _buildInput(
                      "Email", 
                      _emailController, 
                      'assets/icons/ic_email.png', 
                      false,
                      (value) => (value == null || !value.contains('@')) ? 'Email tidak valid' : null
                    ),
                    const SizedBox(height: 15),

                    // Input Sandi
                    _buildInput(
                      "Sandi", 
                      _passwordController, 
                      'assets/icons/ic_lock.png', 
                      true,
                      (value) => (value == null || value.length < 8) ? 'Sandi minimal 8 karakter' : null
                    ),
                    
                    const SizedBox(height: 10),
                    // Checkbox Simpan Akun
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

                    // Tombol Buat Akun
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
                    
                    const SizedBox(height: 15),
                    const Center(child: Text("atau", style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 15),
                    
                    // Tombol Google (Placeholder)
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
                    // Tombol Masuk
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

  // Widget Input Helper
  Widget _buildInput(String hint, TextEditingController controller, String iconPath, bool isPassword, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconPath, width: 20, height: 20, errorBuilder: (_,__,___) => const Icon(Icons.error)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}