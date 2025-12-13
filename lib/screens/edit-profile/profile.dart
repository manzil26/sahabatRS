import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import 'package:sahabat_rs/screens/main-features/halaman-user.dart';
import 'package:sahabat_rs/screens/edit-profile/edit.dart';

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
                Container(
                  width: 144,
                  height: 144,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(0.7),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
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

      // bottom nav share style
      bottomNavigationBar: const _ProfileBottomNavBar(),
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
        vertical: 4,
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

// ================= BOTTOM NAV UNTUK PROFILE =================
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
                    index: 0,
                    icon: Icons.home_filled,
                    label: 'Beranda',
                  ),
                  _ProfileNavItem(
                    index: 1,
                    icon: Icons.history,
                    label: 'Riwayat',
                  ),
                  _ProfileNavItem(
                    index: 2,
                    icon: Icons.message,
                    label: 'Pesan',
                  ),
                  _ProfileNavItem(
                    index: 3,
                    icon: Icons.person,
                    label: 'Profil',
                  ),
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
    super.key,
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
        if (index == currentIndex) {
          // sudah di Profil
          return;
        }
        // 0/1/2 => balik ke HalamanUser dengan tab sesuai
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
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: selected ? -12 : 10,
              child: selected
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
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