import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/auth/register-page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    // Validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        // Navigasi ke Halaman Utama (Home)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        // Pesan error lebih ramah
        String message = "Gagal masuk.";
        if (e.toString().contains("Invalid login credentials")) {
          message = "Email atau sandi salah.";
        } else if (e.toString().contains("Email not confirmed")) {
          message = "Email belum diverifikasi. Cek inbox kamu.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
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
                      "Masuk",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Input Email
                    _buildInput(
                      "Email", 
                      _emailController, 
                      'assets/icons/ic_email.png', 
                      false,
                      (value) {
                        if (value == null || !value.contains('@')) return 'Email tidak valid';
                        return null;
                      }
                    ),
                    const SizedBox(height: 15),

                    // Input Sandi
                    _buildInput(
                      "Sandi", 
                      _passwordController, 
                      'assets/icons/ic_lock.png', 
                      true,
                      (value) {
                        if (value == null || value.isEmpty) return 'Sandi harus diisi';
                        return null;
                      }
                    ),

                    // ... (Sisa UI sama)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text("Lupa sandi?", style: TextStyle(color: Color(0xFF5966B1))),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6A230),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
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
                            const Text("Masuk dengan Google", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum memiliki akun? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                          },
                          child: const Text("Daftar", style: TextStyle(color: Color(0xFF5966B1), fontWeight: FontWeight.bold)),
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

  Widget _buildInput(
    String hint, 
    TextEditingController controller, 
    String iconPath, 
    bool isPassword,
    String? Function(String?)? validator
  ) {
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