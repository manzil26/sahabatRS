// screens/penjadwalan/sajad-tambah.dart

import 'package:flutter/material.dart';
import '../../../../models/jadwal_obat.dart'; 
import '../../../../services/jadwal_service.dart'; 

// --- Konstanta Warna ---
const Color _orangeAksen = Color(0xFFF6A230);
const Color _inputBgColor = Color(0xFFF8F8F6);
const Color _inputTextColor = Color(0xFF333333);
const Color _greyIconColor = Color(0xFF9E9E9E);

enum WaktuMakan { sebelum, saat, sesudah }

class WaktuMakanOption extends StatelessWidget {
  final WaktuMakan value;
  final WaktuMakan selectedValue;
  final ValueChanged<WaktuMakan> onChanged;
  final String assetPath;
  final String label;

  const WaktuMakanOption({
    super.key,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
    required this.assetPath,
    required this.label,
  });

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

class SajadTambahPage extends StatefulWidget {
  const SajadTambahPage({super.key});

  @override
  State<SajadTambahPage> createState() => _SajadTambahPageState();
}

class _SajadTambahPageState extends State<SajadTambahPage> {
  String _namaObat = 'Masukkan Nama Obat';
  int _jumlahObat = 2;
  String _jenisJumlah = 'pil';
  int _durasiHari = 30;

  WaktuMakan _waktuMakanTerpilih = WaktuMakan.saat; 
  TimeOfDay _jamMinum = const TimeOfDay(hour: 10, minute: 0); 
  String _catatan = '';

  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  
  bool _isSaving = false; // Indikator loading saat menyimpan

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamMinum,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _orangeAksen,
            colorScheme: ColorScheme.light(
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

  // --- Fungsi Simpan Data (DIPERBAIKI) ---
  void _simpanJadwal() async {
    if (_namaObatController.text.trim().isEmpty || _jumlahObat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat dan jumlah harus diisi dengan benar.')),
      );
      return;
    }

    setState(() => _isSaving = true); // Mulai loading

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

    final newJadwal = JadwalObat(
      id: 0, 
      idPengguna: '', 
      namaObat: _namaObat,
      jamMinum: _jamMinum,
      jenisWaktuMakan: getJenisWaktuMakan(),
      statusSelesai: false,
      jumlahObat: _jumlahObat,
      durasiHari: _durasiHari,
      catatan: _catatan,
    );

    // Panggil service yang mengembalikan pesan error (String?)
    final errorMessage = await JadwalService.addObat(newJadwal);

    if (!mounted) return;

    setState(() => _isSaving = false); // Stop loading

    if (errorMessage == null) {
      // SUKSES (Error null)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal obat berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
    } else {
      // GAGAL (Tampilkan pesan error asli dari Supabase)
      // Contoh error: "relation 'jadwalobat' does not exist" -> Nama tabel salah
      // Contoh error: "violates row-level security policy" -> Masalah Auth/RLS
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Gagal Menyimpan"),
          content: Text("Detail Error:\n$errorMessage\n\nPastikan Anda sudah login dan tabel 'jadwalobat' ada."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup"),
            )
          ],
        ),
      );
    }
  }

  Widget _buildJumlahDanDurasi() {
    void onChanged(dynamic newValue, String type) {
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

    Widget buildDropdownContainer({
      required Widget child,
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
        child: Center(child: child),
      );
    }

    List<DropdownMenuItem<String>> jumlahItems = [1, 2, 3, 4, 5]
        .map(
          (e) =>
              DropdownMenuItem(value: e.toString(), child: Text(e.toString())),
        )
        .toList();

    List<DropdownMenuItem<String>> jenisItems = ['pil', 'tablet', 'kapsul']
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 14)),
          ),
        )
        .toList();

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
            buildDropdownContainer(
              width: 50,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jumlahObat.toString(),
                  items: jumlahItems,
                  onChanged: (newValue) => onChanged(newValue, 'jumlah'),
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

            buildDropdownContainer(
              width: 80, 
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jenisJumlah,
                  items: jenisItems,
                  onChanged: (newValue) => onChanged(newValue, 'jenis'),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(color: _inputTextColor, fontSize: 16),
                ),
              ),
            ),

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

            buildDropdownContainer(
              width: 60,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _durasiHari.toString(),
                  items: durasiItems,
                  onChanged: (newValue) => onChanged(newValue, 'durasi'),
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

            const Text(
              'Hari',
              style: TextStyle(color: _inputTextColor, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

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
                        ),
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
          maxLines: 4, 
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
            _buildRoundedInputField(
              label: 'Nama Obat',
              controller: _namaObatController,
              prefixIcon: Image.asset(
                'assets/images/penjadwalan/pil.png', 
                width: 24,
                height: 24,
                color: _greyIconColor,
                errorBuilder: (_,__,___) => const Icon(Icons.medication),
              ),
              suffixIcon: const Icon(
                Icons.fullscreen,
                color: _greyIconColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 20),

            _buildJumlahDanDurasi(),

            const SizedBox(height: 20),

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

            _buildNotifikasiInput(),

            const SizedBox(height: 20),

            _buildCatatanInput(),

            const SizedBox(height: 30),
          ],
        ),
      ),

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
            onPressed: _isSaving ? null : _simpanJadwal, // Disable saat loading
            style: ElevatedButton.styleFrom(
              backgroundColor: _orangeAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
            ),
            child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
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