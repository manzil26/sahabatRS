import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body pakai gradient kuning bergradasi (atas pekat -> bawah pucat/putih)
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
        child: Column(
          children: [
            const SizedBox(height: 50),

            // ================= AVATAR + NAMA =================
            Column(
              children: [
                // diameter tetap, border putih TIPIS
                Container(
                  width: 144,
                  height: 144,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding:
                      const EdgeInsets.all(0.7), // border putih lebih tipis
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/user.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Lastri",
                  style: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ================= KOTAK MENU PUTIH (FULL KIRI–KANAN–BAWAH) =================
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
                      onTap: () {},
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== FIXED BOTTOM NAVBAR MENTOK BAWAH =====
      bottomNavigationBar: Container(
        height: 90,
        color: Colors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // bar ungu ditempel ke bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
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
                    _BottomItem(
                      icon: Icons.home_filled,
                      label: "Beranda",
                    ),
                    _BottomItem(
                      icon: Icons.history,
                      label: "Riwayat",
                    ),
                    _BottomItem(
                      icon: Icons.message,
                      label: "Pesan",
                    ),
                    SizedBox(width: 52), // space di bawah ikon Profil
                  ],
                ),
              ),
            ),

            // ikon Profil: icon putih, lingkaran oranye, border putih tebal
            Positioned(
              right: 24,
              top: 0,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white, // border putih
                      shape: BoxShape.circle,
                    ),
                    padding:
                        const EdgeInsets.all(6), // ketebalan border putih
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6A230), // lingkaran oranye
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white, // ikon user putih
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          Color(0xFFF6A230), // tulisan Profil oranye
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET MENU ITEM =================
  Widget menuItem({
    required String iconAsset,
    required String text,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4, // jarak antar fitur biar gak dempet
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            iconAsset,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontFamily: "Rubik",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

// ================= WIDGET ITEM NAV BAR (3 ikon kiri) =================
class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}