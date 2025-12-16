import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart';
import 'package:sahabat_rs/screens/edit-profile/edit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel untuk menampung data profil
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi mengambil data dari tabel 'pengguna'
  Future<void> _fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('pengguna')
          .select()
          .eq('id_pengguna', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback jika data masih loading atau kosong
    final String displayName = _profileData?['name'] ?? "Pengguna";
    final String displayPhone = _profileData?['nomor_telepon'] ?? "-";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6C53A), // kuning atas
              Color(0xFFFFF7E6), // putih hangat
              Color(0xFFE4E6F7), // ungu muda
              Color(0xFF5966B1), // ungu bawah
            ],
            stops: [0.0, 0.45, 0.8, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 50),

                  // ================= AVATAR + NAMA =================
                  Column(
                    children: [
                      Container(
                        width: 144,
                        height: 144,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          // TODO: Bisa integrasi storage untuk foto asli
                          child: Image.asset(
                            "assets/images/user.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: "Rubik",
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        displayPhone,
                        style: TextStyle(
                          fontFamily: "Rubik",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= KOTAK MENU PUTIH =================
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          menuItem(
                            iconAsset: "assets/images/profil.png",
                            text: "Edit Profil",
                            bgColor: const Color(0xFF5966B1).withOpacity(0.4),
                            onTap: () async {
                              // Navigasi ke Edit dan tunggu hasil (refresh saat kembali)
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              );
                              // Refresh data setelah edit
                              _fetchUserProfile();
                            },
                          ),
                          menuItem(
                            iconAsset: "assets/images/notifikasi.png",
                            text: "Notifikasi",
                            bgColor: const Color(0xFFF6A230).withOpacity(0.4),
                          ),
                          menuItem(
                            iconAsset: "assets/images/asuransi.png",
                            text: "Asuransi",
                            bgColor: const Color(0xFF5966B1).withOpacity(0.4),
                          ),
                          menuItem(
                            iconAsset: "assets/images/keluarga.png",
                            text: "Keluarga",
                            bgColor: const Color(0xFFF6A230).withOpacity(0.4),
                            onTap: () {
                              Navigator.of(context).pushNamed('/salacak');
                            },
                          ),
                          menuItem(
                            iconAsset: "assets/images/pengaturan.png",
                            text: "Pengaturan",
                            bgColor: const Color(0xFF5966B1).withOpacity(0.4),
                          ),
                          const Divider(height: 28),
                          menuItem(
                            iconAsset: "assets/images/keluar.png",
                            text: "Keluar",
                            bgColor: Colors.grey.shade300,
                            onTap: () async {
                              await Supabase.instance.client.auth.signOut();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const _ProfileBottomNavBar(),
    );
  }

  Widget menuItem({
    required String iconAsset,
    required String text,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            iconAsset,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.circle, size: 10),
          ),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontFamily: "Rubik",
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

// ================= BOTTOM NAV (Sama seperti sebelumnya) =================
class _ProfileBottomNavBar extends StatelessWidget {
  const _ProfileBottomNavBar();

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 3;
    const orange = Color(0xFFF6A230);

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5966B1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _ProfileNavItem(
                      index: 0, icon: Icons.home_filled, label: 'Beranda'),
                  _ProfileNavItem(
                      index: 1, icon: Icons.history, label: 'Riwayat'),
                  _ProfileNavItem(
                      index: 2, icon: Icons.message, label: 'Pesan'),
                  _ProfileNavItem(
                      index: 3, icon: Icons.person, label: 'Profil'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;

  const _ProfileNavItem({
    required this.index,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 3;
    const orange = Color(0xFFF6A230);
    final bool selected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (index == currentIndex) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HalamanUser(initialIndex: index),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: selected ? -12 : 10,
              child: selected
                  ? Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: orange, shape: BoxShape.circle),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 24),
            ),
            Positioned(
              bottom: 8,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? orange : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}