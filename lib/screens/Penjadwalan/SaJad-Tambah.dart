// screens/penjadwalan/sajad-tambah.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/jadwal_obat.dart'; // Import model
import '../../../../services/jadwal_service.dart'; // Import service

// --- Konstanta Warna ---
const Color _orangeAksen = Color(0xFFF6A230);
const Color _inputBgColor = Color(0xFFF8F8F6);
const Color _inputTextColor = Color(0xFF333333);
const Color _greyIconColor = Color(0xFF9E9E9E);

// --- Tipe Enum untuk Waktu Makan ---
// Memastikan nilai enum cocok dengan ENUM database: 'sebelum_makan', 'sesudah_makan'
enum WaktuMakan { sebelum, saat, sesudah }

// --- Widget untuk Pilihan Waktu Makan Kustom (TIDAK BERUBAH) ---
class WaktuMakanOption extends StatelessWidget {
  final WaktuMakan value;
  final WaktuMakan selectedValue;
  final ValueChanged<WaktuMakan> onChanged;
  final String assetPath;
  final String label;

  const WaktuMakanOption({
    Key? key,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
    required this.assetPath,
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
            width: 80,
            height: 80,
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
              child: Image.asset(
                assetPath,
                width: 40,
                height: 40,
                color: isSelected ? Colors.white : _greyIconColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? _orangeAksen : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Kustom untuk Input Field (Contoh: Nama Obat) ---
Widget _buildRoundedInputField({
  required String label,
  required TextEditingController controller,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool readOnly = false,
  VoidCallback? onTap,
  String? initialValue,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          absorbing: readOnly,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBgColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: prefixIcon,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: suffixIcon,
                    )
                  : null,
              hintText: initialValue,
              hintStyle: TextStyle(color: _inputTextColor),
            ),
            style: TextStyle(color: _inputTextColor, fontSize: 16),
          ),
        ),
      ),
    ],
  );
}

// --- Sajad Tambah Page ---
class SajadTambahPage extends StatefulWidget {
  const SajadTambahPage({Key? key}) : super(key: key);

  @override
  State<SajadTambahPage> createState() => _SajadTambahPageState();
}

class _SajadTambahPageState extends State<SajadTambahPage> {
  // State untuk form
  String _namaObat = 'Masukkan Nama Obat';
  int _jumlahObat = 2;
  String _jenisJumlah = 'pil'; // atau 'tablet', 'sendok', dll.
  int _durasiHari = 30;

  WaktuMakan _waktuMakanTerpilih = WaktuMakan.saat; // Sesuai gambar
  TimeOfDay _jamMinum = const TimeOfDay(hour: 10, minute: 0); // Sesuai gambar
  String _catatan = '';

  // Controller untuk field yang kompleks
  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaObatController.addListener(() {
      _namaObat = _namaObatController.text;
    });
    _catatanController.addListener(() {
      _catatan = _catatanController.text;
    });
  }

  @override
  void dispose() {
    _namaObatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamMinum,
      builder: (context, child) {
        // Kustomisasi warna Time Picker (opsional)
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _orangeAksen,
            colorScheme: ColorScheme.light(
              primary: _orangeAksen, // Warna aksen untuk jam yang dipilih
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

  // Fungsi untuk menyimpan data (DIUBAH)
  void _simpanJadwal() async {
    // Dibuat async
    // 1. Validasi
    if (_namaObatController.text.isEmpty || _jumlahObat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat dan jumlah harus diisi.')),
      );
      return;
    }

    // Logic untuk mengkonversi WaktuMakan enum ke string database
    String getJenisWaktuMakan() {
      switch (_waktuMakanTerpilih) {
        case WaktuMakan.sebelum:
          return 'sebelum_makan';
        case WaktuMakan.sesudah:
          return 'sesudah_makan';
        case WaktuMakan.saat:
        default:
          return 'saat_makan';
      }
    }

    // 2. Buat objek JadwalObat
    final newJadwal = JadwalObat(
      id: 0, 
      idPengguna: '', // Kosongkan saja, nanti diisi otomatis di Service pakai UUID asli
      namaObat: _namaObat,
      jamMinum: _jamMinum,
      jenisWaktuMakan: getJenisWaktuMakan(),
      statusSelesai: false,
      jumlahObat: _jumlahObat,
      durasiHari: _durasiHari,
      catatan: _catatan,
    );

    // 3. Panggil Service untuk Add Data
    final success = await JadwalService.addObat(newJadwal);

    String message;
    if (success) {
      message = 'Jadwal obat berhasil ditambahkan.';
    } else {
      message = 'Gagal menambahkan jadwal obat.';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    // 4. Kembali ke halaman sebelumnya
    Navigator.of(context).pop();
  }

  // --- Widget Kustom untuk Pilihan Jumlah & Durasi (2 Pil - 30 Hari) ---
  Widget _buildJumlahDanDurasi() {
    // Fungsi yang akan dipanggil saat perubahan terjadi pada Dropdown
    void _onChanged(dynamic newValue, String type) {
      setState(() {
        if (type == 'jumlah') {
          _jumlahObat = int.parse(newValue);
        } else if (type == 'jenis') {
          _jenisJumlah = newValue;
        } else if (type == 'durasi') {
          _durasiHari = int.parse(newValue);
        }
      });
    }

    // Builder untuk wadah input
    Widget _buildDropdownContainer({
      required Widget child,
      double width = 80, // Default width
    }) {
      return Container(
        width: width,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: _inputBgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: child),
      );
    }

    // Opsi untuk Jumlah Pil (Simulasi 1-5)
    List<DropdownMenuItem<String>> jumlahItems = [1, 2, 3, 4, 5]
        .map(
          (e) =>
              DropdownMenuItem(value: e.toString(), child: Text(e.toString())),
        )
        .toList();

    // Opsi untuk Jenis Jumlah (Pil, Tablet, Kapsul)
    List<DropdownMenuItem<String>> jenisItems = ['pil', 'tablet', 'kapsul']
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 14)),
          ),
        )
        .toList();

    // Opsi untuk Durasi Hari (Simulasi 1-30)
    List<DropdownMenuItem<String>> durasiItems =
        List.generate(30, (index) => index + 1)
            .map(
              (e) => DropdownMenuItem(
                value: e.toString(),
                child: Text(e.toString()),
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah & Berapa lama?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            // 1. Jumlah Obat (2)
            _buildDropdownContainer(
              width: 50,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jumlahObat.toString(),
                  items: jumlahItems,
                  onChanged: (newValue) => _onChanged(newValue, 'jumlah'),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(
                    color: _inputTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Jenis Jumlah (pil)
            _buildDropdownContainer(
              width: 80, // Lebih lebar untuk teks 'pil'
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jenisJumlah,
                  items: jenisItems,
                  onChanged: (newValue) => _onChanged(newValue, 'jenis'),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(color: _inputTextColor, fontSize: 16),
                ),
              ),
            ),

            // Icon Kalender (Simulasi)
            const SizedBox(width: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _inputBgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 20,
                color: _greyIconColor,
              ),
            ),

            const SizedBox(width: 10),

            // 3. Durasi Hari (30 Hari)
            _buildDropdownContainer(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _durasiHari.toString(),
                  items: durasiItems,
                  onChanged: (newValue) => _onChanged(newValue, 'durasi'),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(
                    color: _inputTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Teks 'Hari'
            const Text(
              'Hari',
              style: TextStyle(color: _inputTextColor, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  // --- Widget Kustom untuk Notifikasi (Input Waktu) ---
  Widget _buildNotifikasiInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
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
                      const Icon(
                        Icons.notifications_none,
                        color: _greyIconColor,
                        size: 22,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _jamMinum.format(
                          context,
                        ), // Menampilkan waktu yang dipilih
                        style: const TextStyle(
                          color: _inputTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Tombol Tambah Waktu
            InkWell(
              onTap: () {
                print('Tambah waktu notifikasi');
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _inputBgColor,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Icon(Icons.add, color: _greyIconColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Widget Kustom untuk Catatan (Text Area) ---
  Widget _buildCatatanInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _catatanController,
          maxLines: 4, // Membuatnya terlihat seperti text area
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputBgColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
            hintText: 'Tambahkan catatan di sini (opsional)...',
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: TextStyle(color: _inputTextColor, fontSize: 16),
        ),
      ],
    );
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Tambahkan Jadwal Obat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        // Garis pemisah di bawah AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),

      // --- Body ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Nama Obat
            _buildRoundedInputField(
              label: 'Nama Obat',
              controller: _namaObatController,
              prefixIcon: Image.asset(
                'assets/images/penjadwalan/pil.png', // Sesuaikan path asset Anda
                width: 24,
                height: 24,
                color: _greyIconColor,
              ),
              suffixIcon: const Icon(
                Icons.fullscreen,
                color: _greyIconColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 20),

            // 2. Jumlah & Berapa lama?
            _buildJumlahDanDurasi(),

            const SizedBox(height: 20),

            // 3. Makanan & Pil
            const Text(
              'Makanan & Pil',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WaktuMakanOption(
                  value: WaktuMakan.sebelum,
                  selectedValue: _waktuMakanTerpilih,
                  onChanged: (val) => setState(() => _waktuMakanTerpilih = val),
                  assetPath: 'assets/images/penjadwalan/piring.png',
                  label: 'Sebelum Makan',
                ),

                WaktuMakanOption(
                  value: WaktuMakan.sesudah,
                  selectedValue: _waktuMakanTerpilih,
                  onChanged: (val) => setState(() => _waktuMakanTerpilih = val),
                  assetPath: 'assets/images/penjadwalan/piring.png',
                  label: 'Sesudah Makan',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Notifikasi
            _buildNotifikasiInput(),

            const SizedBox(height: 20),

            // 5. Catatan
            _buildCatatanInput(),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // --- Floating Action Button (DONE) ---
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
            onPressed: _simpanJadwal,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orangeAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Done',
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
}
