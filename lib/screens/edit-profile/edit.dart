import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import 'package:sahabat_rs/screens/edit-profile/profile.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isEditing = true;

  final TextEditingController nameController =
      TextEditingController(text: "Lastri");
  final TextEditingController ageController =
      TextEditingController(text: "73 tahun");
  final TextEditingController genderController =
      TextEditingController(text: "Perempuan");
  final TextEditingController phoneController =
      TextEditingController(text: "08976534023");

  final List<String> allConditions = const [
    "Pengguna Tongkat",
    "Medical Check-Up Rutin",
    "Gangguan Pendengaran",
  ];
  late List<String> selectedConditions;

  final ImagePicker _picker = ImagePicker();
  Uint8List? pickedImageBytes;

  @override
  void initState() {
    super.initState();
    selectedConditions = List.from(allConditions);
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        pickedImageBytes = bytes;
      });
    }
  }

  void _onSave() {
    setState(() {
      isEditing = false;
    });
    // TODO: simpan ke backend / Supabase kalau sudah siap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7D36D),
              Color(0xFFF7E9A8),
              Colors.white,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ===== APPBAR =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      isEditing ? "Simpan Profil" : "Edit Profil",
                      style: const TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: _onSave,
                          )
                        : TextButton(
                            onPressed: () {
                              setState(() => isEditing = true);
                            },
                            child: const Text(
                              "Edit",
                              style: TextStyle(
                                fontFamily: "Rubik",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              // ===== AVATAR =====
              const SizedBox(height: 6),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 137,
                      height: 137,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(1.1),
                      child: ClipOval(
                        child: pickedImageBytes == null
                            ? Image.asset(
                                "assets/images/user.png",
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                pickedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: InkWell(
                        onTap: isEditing ? _pickProfileImage : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF5966B1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== FORM PUTIH (SCROLLABLE) =====
              Expanded(
                child: ClipRect(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Nama"),
                          _buildField(nameController),
                          const SizedBox(height: 20),

                          _buildLabel("Umur"),
                          _buildField(ageController),
                          const SizedBox(height: 20),

                          _buildLabel("Gender"),
                          _buildField(genderController),
                          const SizedBox(height: 20),

                          _buildLabel("Kondisi"),
                          const SizedBox(height: 8),
                          _buildConditionChips(),
                          const SizedBox(height: 20),

                          _buildLabel("Nomor Telepon"),
                          _buildField(
                            phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // bottom nav share style
      bottomNavigationBar: const _EditProfileBottomNavBar(),
    );
  }

  // ==============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: "Rubik",
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      enabled: isEditing,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: const TextStyle(fontFamily: "Rubik", fontSize: 14),
    );
  }

  Widget _buildConditionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allConditions.map((cond) {
        final selected = selectedConditions.contains(cond);

        return FilterChip(
          label: Text(
            cond,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: "Rubik",
            ),
          ),
          selected: selected,
          selectedColor: const Color(0xFFF6A230),
          backgroundColor: const Color(0xFFF6A230),
          onSelected: isEditing
              ? (value) {
                  setState(() {
                    if (value) {
                      selectedConditions.add(cond);
                    } else {
                      selectedConditions.remove(cond);
                    }
                  });
                }
              : null,
        );
      }).toList(),
    );
  }
}

// ================= BOTTOM NAV UNTUK EDIT PROFILE =================
class _EditProfileBottomNavBar extends StatelessWidget {
  const _EditProfileBottomNavBar();

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
                  _EditNavItem(
                    index: 0,
                    icon: Icons.home_filled,
                    label: 'Beranda',
                  ),
                  _EditNavItem(
                    index: 1,
                    icon: Icons.history,
                    label: 'Riwayat',
                  ),
                  _EditNavItem(
                    index: 2,
                    icon: Icons.message,
                    label: 'Pesan',
                  ),
                  _EditNavItem(
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

class _EditNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;

  const _EditNavItem({
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
          // Profil → balik ke ProfilePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfilePage(),
            ),
          );
          return;
        }

        // 0/1/2 → balik ke HalamanUser tab sesuai
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 35c9e0c (Update profile & halaman user)
