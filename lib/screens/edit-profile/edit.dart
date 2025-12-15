import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sahabat_rs/screens/edit-profile/profile.dart';
import 'package:sahabat_rs/screens/main-features/halaman-user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isEditing = false; // Default false agar user harus klik 'Edit' dulu
  bool isLoading = true;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Gender Dropdown
  String? selectedGender;
  final List<String> genderOptions = ["Laki-laki", "Perempuan"];

  // Kondisi Kesehatan (Filter Chips)
  final List<String> allConditions = const [
    "Pengguna Tongkat",
    "Medical Check-Up Rutin",
    "Gangguan Pendengaran",
    "Diabetes",
    "Hipertensi",
    "Asma",
  ];
  List<String> selectedConditions = [];

  // Gambar
  final ImagePicker _picker = ImagePicker();
  Uint8List? pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. AMBIL DATA DARI SUPABASE ---
  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('pengguna')
          .select()
          .eq('id_pengguna', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          nameController.text = data['name'] ?? '';
          phoneController.text = data['nomor_telepon'] ?? '';
          addressController.text = data['alamat'] ?? '';
          
          // Parsing umur (integer ke string)
          if (data['umur'] != null) {
            ageController.text = data['umur'].toString();
          }

          // Parsing gender
          if (genderOptions.contains(data['gender'])) {
            selectedGender = data['gender'];
          }

          // Parsing kondisi (String dipisah koma -> List)
          if (data['kondisi'] != null && (data['kondisi'] as String).isNotEmpty) {
            selectedConditions = (data['kondisi'] as String)
                .split(',')
                .map((e) => e.trim())
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint("Error load user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- 2. UPDATE DATA KE SUPABASE ---
  Future<void> _onSave() async {
    setState(() => isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Konversi kondisi list ke string (dipisah koma)
      String kondisiString = selectedConditions.join(', ');

      // Upsert ke tabel 'pengguna'
      await Supabase.instance.client.from('pengguna').upsert({
        'id_pengguna': user.id,
        'name': nameController.text,
        'nomor_telepon': phoneController.text,
        'alamat': addressController.text,
        'umur': int.tryParse(ageController.text) ?? 0,
        'gender': selectedGender,
        'kondisi': kondisiString,
        // 'updated_at': DateTime.now().toIso8601String(), // Optional jika ada kolom updated_at
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditing = false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e")),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        pickedImageBytes = bytes;
      });
      // TODO: Upload bytes ke Supabase Storage bucket 'avatars'
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && !isEditing) {
      // Loading screen saat awal
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      isEditing ? "Simpan Profil" : "Detail Profil",
                      style: const TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    isEditing
                        ? (isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: _onSave,
                              ))
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
                      padding: const EdgeInsets.all(4),
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
                          _buildLabel("Nama Lengkap"),
                          _buildField(nameController),
                          const SizedBox(height: 20),

                          _buildLabel("Umur"),
                          _buildField(ageController, keyboardType: TextInputType.number),
                          const SizedBox(height: 20),

                          _buildLabel("Gender"),
                          const SizedBox(height: 8),
                          _buildGenderDropdown(),
                          const SizedBox(height: 20),

                          _buildLabel("Kondisi Kesehatan"),
                          const SizedBox(height: 8),
                          _buildConditionChips(),
                          const SizedBox(height: 20),

                          _buildLabel("Nomor Telepon"),
                          _buildField(
                            phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel("Alamat"),
                          _buildField(addressController, maxLines: 3),
                          
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
      bottomNavigationBar: const _EditProfileBottomNavBar(),
    );
  }

  // ================= HELPER WIDGETS =================

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
    int maxLines = 1,
  }) {
    return TextField(
      enabled: isEditing,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontFamily: "Rubik", fontSize: 14),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: const Text("Pilih Gender"),
          isExpanded: true,
          items: genderOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: isEditing
              ? (newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                }
              : null,
        ),
      ),
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
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: "Rubik",
            ),
          ),
          selected: selected,
          selectedColor: const Color(0xFFF6A230),
          backgroundColor: Colors.grey.shade200,
          checkmarkColor: Colors.white,
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

// ================= BOTTOM NAV (Reused) =================
class _EditProfileBottomNavBar extends StatelessWidget {
  const _EditProfileBottomNavBar();

  @override
  Widget build(BuildContext context) {
    // Statis saja, karena navigasi akan mereset halaman
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
                      index: 0, icon: Icons.home_filled, label: 'Beranda'),
                  _EditNavItem(
                      index: 1, icon: Icons.history, label: 'Riwayat'),
                  _EditNavItem(
                      index: 2, icon: Icons.message, label: 'Pesan'),
                  _EditNavItem(
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

class _EditNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;

  const _EditNavItem({
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
          // Jika tekan profil lagi, kembali ke read-only profile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
          return;
        }
        // Navigasi ke halaman lain
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HalamanUser(initialIndex: index)),
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