// screens/penjadwalan/sajad-edit.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/jadwal_obat.dart';
import '../../../../services/jadwal_service.dart';

// --- Konstanta Warna ---
const Color _orangeAksen = Color(0xFFF6A230); // Warna Orange/Aksen
const Color _redAksen = Colors.red;
const Color _inputBgColor = Color(0xFFF8F8F6);
const Color _inputTextColor = Color(0xFF333333);
const Color _greyIconColor = Color(0xFF9E9E9E);

// --- Tipe Enum untuk Waktu Makan ---
enum WaktuMakan { sebelum, sesudah }

// Widget Kustom untuk Pilihan Waktu Makan (TIDAK BERUBAH)
class WaktuMakanOption extends StatelessWidget {
  final WaktuMakan value;
  final WaktuMakan selectedValue;
  final ValueChanged<WaktuMakan> onChanged;
  final String label;

  const WaktuMakanOption({
    Key? key,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isSelected ? _orangeAksen : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? _orangeAksen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _orangeAksen.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              // Menggunakan Icon Piring Sederhana
              child: Icon(
                Icons.restaurant,
                size: 40,
                color: isSelected ? Colors.white : _greyIconColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? _orangeAksen : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk Input Waktu (Notifikasi) (TIDAK BERUBAH)
Widget _buildTimeInput({
  required TimeOfDay time,
  required BuildContext context,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_none, color: _greyIconColor, size: 22),
          const SizedBox(width: 15),
          Text(
            time.format(context),
            style: const TextStyle(
              color: _inputTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper Widgets (disadur dari sajad-tambah)
Widget _buildFieldContainer(
  BuildContext context,
  TextEditingController controller,
  String hint, {
  double width = 80,
}) {
  return Container(
    width: width,
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: _inputBgColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget _buildDropdownContainer(
  BuildContext context,
  String initialValue, {
  required List<String> items,
}) {
  return Container(
    width: 80,
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: _inputBgColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: initialValue,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            // Handle perubahan jenis (pil/tablet) jika diperlukan
          },
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: _greyIconColor,
          ),
          style: const TextStyle(color: _inputTextColor, fontSize: 16),
        ),
      ),
    ),
  );
}

Widget _buildIconContainer(IconData iconData) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: _inputBgColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(iconData, size: 24, color: _greyIconColor),
  );
}

class SajadEditPage extends StatefulWidget {
  final JadwalObat obat;

  const SajadEditPage({Key? key, required this.obat}) : super(key: key);

  @override
  State<SajadEditPage> createState() => _SajadEditPageState();
}

class _SajadEditPageState extends State<SajadEditPage> {
  // State data yang akan di-edit
  late TextEditingController _namaObatController;
  late TextEditingController _jumlahObatController;
  late TextEditingController _durasiHariController;
  late TextEditingController _catatanController;
  late TimeOfDay _jamMinum;
  late WaktuMakan _waktuMakanTerpilih;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Controller dengan data dari widget.obat
    _namaObatController = TextEditingController(text: widget.obat.namaObat);
    _jumlahObatController = TextEditingController(
      text: widget.obat.jumlahObat?.toString() ?? '2',
    );
    _durasiHariController = TextEditingController(
      text: widget.obat.durasiHari?.toString() ?? '30',
    );
    _catatanController = TextEditingController(
      text: widget.obat.catatan ?? 'Tambahkan Catatan',
    );
    _jamMinum = widget.obat.jamMinum;

    // Konversi string jenis waktu makan ke enum
    if (widget.obat.jenisWaktuMakan.contains('sebelum')) {
      _waktuMakanTerpilih = WaktuMakan.sebelum;
    } else {
      _waktuMakanTerpilih = WaktuMakan.sesudah;
    }
  }

  @override
  void dispose() {
    _namaObatController.dispose();
    _jumlahObatController.dispose();
    _durasiHariController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamMinum,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _orangeAksen,
            colorScheme: const ColorScheme.light(
              primary: _orangeAksen,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _jamMinum) {
      setState(() {
        _jamMinum = picked;
      });
    }
  }

  void _simpanPerubahan() async {
    // Dibuat ASYNC
    // 1. Validasi
    if (_namaObatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama obat wajib diisi.')));
      return;
    }

    // 2. Buat objek yang diperbarui
    final updatedObat = JadwalObat(
      id: widget.obat.id,
      idPengguna: widget.obat.idPengguna, // Sudah String (UUID)
      namaObat: _namaObatController.text,
      jamMinum: _jamMinum,
      jenisWaktuMakan: _waktuMakanTerpilih == WaktuMakan.sebelum
          ? 'sebelum_makan'
          : 'sesudah_makan',
      statusSelesai: widget.obat.statusSelesai,
      jumlahObat: int.tryParse(_jumlahObatController.text),
      durasiHari: int.tryParse(_durasiHariController.text),
      catatan: _catatanController.text,
    );

    // 3. Panggil Service untuk Update Data
    final success = await JadwalService.updateObat(updatedObat);

    String message;
    if (success) {
      message = 'Jadwal obat berhasil diperbarui.';
    } else {
      message = 'Gagal memperbarui jadwal obat. Cek koneksi atau ID database.';
    }

    // Tampilkan pesan
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    // 4. Kembali ke halaman Home
    Navigator.of(context).pop();
  }

  void _hapusJadwal() async {
    // Dibuat ASYNC
    // 1. Tampilkan Dialog Konfirmasi
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Diperbaiki dari AltertDialog ke AlertDialog
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus jadwal obat ${widget.obat.namaObat}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: _redAksen)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // 2. Jika dikonfirmasi, lakukan penghapusan
    if (konfirmasi == true) {
      final success = await JadwalService.deleteObat(widget.obat.id);
      String message;
      if (success) {
        message = 'Jadwal obat berhasil dihapus.';
      } else {
        message = 'Gagal menghapus jadwal obat. Cek koneksi atau ID database.';
      }

      // Tampilkan pesan dan kembali ke halaman sebelumnya (Home)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Pengingat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _hapusJadwal,
            child: const Text(
              'Hapus',
              style: TextStyle(color: _redAksen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Nama Obat ---
            const Text(
              'Nama Obat',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _inputBgColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: _namaObatController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Image.asset(
                      'assets/images/penjadwalan/pil.png',
                      width: 24,
                      height: 24,
                      color: _greyIconColor,
                    ),
                  ),
                  suffixIcon: const Icon(
                    Icons.fullscreen,
                    color: _greyIconColor,
                    size: 24,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: _inputTextColor),
              ),
            ),
            const SizedBox(height: 20),

            // --- Jumlah & Berapa lama? ---
            const Text(
              'Jumlah & Berapa lama?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildFieldContainer(context, _jumlahObatController, '2'),
                const SizedBox(width: 10),
                _buildDropdownContainer(
                  context,
                  'pil',
                  items: ['pil', 'tablet'],
                ),
                const SizedBox(width: 20),
                _buildIconContainer(Icons.calendar_today),
                const SizedBox(width: 10),
                _buildFieldContainer(context, _durasiHariController, '30'),
                const SizedBox(width: 10),
                const Text(
                  'Hari',
                  style: TextStyle(fontSize: 16, color: _inputTextColor),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Makanan & Pil ---
            const Text(
              'Makanan & Pil',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WaktuMakanOption(
                  value: WaktuMakan.sebelum,
                  selectedValue: _waktuMakanTerpilih,
                  onChanged: (val) => setState(() => _waktuMakanTerpilih = val),
                  label: 'Sebelum Makan',
                ),
                WaktuMakanOption(
                  value: WaktuMakan.sesudah,
                  selectedValue: _waktuMakanTerpilih,
                  onChanged: (val) => setState(() => _waktuMakanTerpilih = val),
                  label: 'Sesudah Makan',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Notifikasi ---
            const Text(
              'Notifikasi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInput(
                    time: _jamMinum,
                    context: context,
                    onTap: () => _selectTime(context),
                  ),
                ),
                const SizedBox(width: 10),
                _buildIconContainer(Icons.add),
              ],
            ),
            const SizedBox(height: 20),

            // --- Catatan ---
            const Text(
              'Catatan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _inputBgColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: _catatanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tambahkan Catatan',
                ),
                style: TextStyle(
                  color: _inputTextColor.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // --- Tombol Simpan ---
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          MediaQuery.of(context).padding.bottom + 10,
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _simpanPerubahan,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orangeAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets (disadur dari sajad-tambah)
  Widget _buildFieldContainer(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    double width = 80,
  }) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer(
    BuildContext context,
    String initialValue, {
    required List<String> items,
  }) {
    return Container(
      width: 80,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: initialValue,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (newValue) {
              // Handle perubahan jenis (pil/tablet) jika diperlukan
            },
            isDense: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: _greyIconColor,
            ),
            style: const TextStyle(color: _inputTextColor, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData iconData) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(iconData, size: 24, color: _greyIconColor),
    );
  }
}
