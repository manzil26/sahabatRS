import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'edit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // HEADER GRADIENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7D36D), Color(0xFFF7E9A8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage("assets/images/profil.png"),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lastri",
                  style: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),

          // MENU LIST
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                children: [
                  menuItem(
                    icon: Mdi.account_circle,
                    text: "Edit Profil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    },
                  ),
                  menuItem(icon: Mdi.bell, text: "Notifikasi"),
                  menuItem(icon: Mdi.shield, text: "Asuransi"),
                  menuItem(icon: Mdi.account_group, text: "Keluarga"),
                  menuItem(icon: Mdi.cog, text: "Pengaturan"),
                  const Divider(),
                  menuItem(icon: Mdi.logout, text: "Keluar"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem({
    required String icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFECE0B3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Iconify(icon, size: 28),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontFamily: "Rubik",
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

