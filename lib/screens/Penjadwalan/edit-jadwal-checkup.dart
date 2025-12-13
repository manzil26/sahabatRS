// screens/penjadwalan/edit-jadwal-checkup.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/jadwal_checkup_detail.dart';
import '../../../../services/jadwal_service.dart';

// --- Konstanta Warna ---
const Color _orangeAksen = Color(0xFFF6A230);
const Color _redAksen = Colors.red;
const Color _inputBgColor = Color(0xFFF8F8F6);
const Color _inputTextColor = Color(0xFF333333);
const Color _greyIconColor = Color(0xFF9E9E9E);

// --- Widget Kustom untuk Input Field (Dipertahankan) ---
Widget _buildRoundedInputField({
  required String label,
  required TextEditingController controller,
  required IconData iconData,
  String hintText = '',
  bool readOnly = false,
  VoidCallback? onTap,
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
            maxLines: (label == 'Kondisi' || label == 'Kegiatan') ? 3 : 1,
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
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Icon(iconData, color: _greyIconColor, size: 24),
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: _inputTextColor.withOpacity(0.5)),
            ),
            style: const TextStyle(color: _inputTextColor, fontSize: 16),
          ),
        ),
      ),
    ],
  );
}

// --- Halaman Edit Jadwal Check-Up ---
class EditJadwalCheckupPage extends StatefulWidget {
  final JadwalCheckUpDetail detail; // Menerima data yang akan di-edit

  const EditJadwalCheckupPage({super.key, required this.detail});

  @override
  State<EditJadwalCheckupPage> createState() => _EditJadwalCheckupPageState();
}

class _EditJadwalCheckupPageState extends State<EditJadwalCheckupPage> {
  // State untuk data form
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  // Controllers untuk input text
  late TextEditingController _dateController;
  late TextEditingController _lokasiController;
  late TextEditingController _kegiatanController;
  late TextEditingController _kondisiController;

  // Controller untuk waktu
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    // 1. Isi state dan controller dengan data yang diterima
    _selectedDate = widget.detail.tanggal;
    _selectedTime =
        widget.detail.waktuNotifikasi ?? const TimeOfDay(hour: 10, minute: 0);

    // 2. Inisialisasi Controllers
    _dateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
    );
    _lokasiController = TextEditingController(text: widget.detail.lokasi);
    _kegiatanController = TextEditingController(text: widget.detail.kegiatan);
    _kondisiController = TextEditingController(
      text: widget.detail.kondisiTambahan,
    );
    _timeController =
        TextEditingController(); // Inisialisasi awal di didChangeDependencies/build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // PERBAIKAN: Inisialisasi _timeController di sini (context aman)
    if (_timeController.text.isEmpty) {
      _updateTimeController(context);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _lokasiController.dispose();
    _kegiatanController.dispose();
    _kondisiController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Fungsionalitas Picker (Sama seperti Tambah)

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _orangeAksen,
            colorScheme: ColorScheme.light(
              primary: _orangeAksen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _updateTimeController(context);
      });
    }
  }

  void _updateTimeController(BuildContext context) {
    // PERBAIKAN: Fungsi ini hanya untuk set controller, tanpa setState di sini
    _timeController.text = _selectedTime.format(context);
  }

  // Fungsi Hapus (dengan konfirmasi dan panggilan service)
  void _hapusCheckup() async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Jadwal Checkup'),
          content: Text(
            'Anda yakin ingin menghapus jadwal checkup pada ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}?',
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

    if (konfirmasi == true) {
      // Panggil service delete
      final success = await JadwalService.deleteCheckup(
        widget.detail.idCheckup,
      );

      String message = success
          ? 'Jadwal berhasil dihapus.'
          : 'Gagal menghapus jadwal.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // Kembali ke halaman kalender (yang akan di-refresh)
      Navigator.of(context).pop();
    }
  }

  // --- Fungsi Simpan (UPDATE) ---
  void _simpanCheckup() async {
    if (_lokasiController.text.trim().isEmpty ||
        _kegiatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi dan Kegiatan wajib diisi.')),
      );
      return;
    }

    // 1. Buat objek yang diperbarui
    final updatedCheckup = JadwalCheckUpDetail(
      idCheckup: widget.detail.idCheckup,
      tanggal: _selectedDate,
      lokasi: _lokasiController.text.trim(),
      kegiatan: _kegiatanController.text.trim(),
      kondisiTambahan: _kondisiController.text.trim(),
      waktuNotifikasi: _selectedTime,
    );

    // 2. Panggil Service untuk Update Data
    // Asumsi: JadwalService.updateCheckup sudah diimplementasikan
    final success = await JadwalService.updateCheckup(updatedCheckup);

    String message = success
        ? 'Jadwal Checkup berhasil diperbarui.'
        : 'Gagal memperbarui Jadwal Checkup.';

    // 3. Tampilkan pesan dan kembali
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
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
              child: _buildRoundedInputField(
                label: 'Notifikasi',
                controller: _timeController,
                iconData: Icons.notifications_none,
                readOnly: true,
                onTap: () => _selectTime(context),
                hintText: _timeController.text.isEmpty
                    ? '10:00 AM'
                    : _timeController.text,
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
          'Edit Jadwal Checkup', // Judul Edit
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Tombol HAPUS
          TextButton(
            onPressed: _hapusCheckup,
            child: const Text(
              'Hapus',
              style: TextStyle(color: _redAksen, fontWeight: FontWeight.w600),
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
            // 1. Tanggal
            _buildRoundedInputField(
              label: 'Tanggal',
              controller: _dateController,
              iconData: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context),
              hintText: 'Pilih Tanggal',
            ),
            const SizedBox(height: 20),

            // 2. Lokasi
            _buildRoundedInputField(
              label: 'Lokasi',
              controller: _lokasiController,
              iconData: Icons.book_outlined,
              hintText: 'Rumah Sakit / Klinik',
              readOnly: false,
            ),
            const SizedBox(height: 20),

            // 3. Kegiatan
            _buildRoundedInputField(
              label: 'Kegiatan',
              controller: _kegiatanController,
              iconData: Icons.checklist_rtl,
              hintText: 'Masukkan detail kegiatan',
              readOnly: false,
            ),
            const SizedBox(height: 20),

            // 4. Notifikasi
            _buildNotifikasiInput(),
            const SizedBox(height: 20),

            // 5. Kondisi
            _buildRoundedInputField(
              label: 'Kondisi',
              controller: _kondisiController,
              iconData: Icons.local_hospital_outlined,
              hintText: 'Tambahkan kondisi tambahan (dipisahkan koma)',
              readOnly: false,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // --- Floating Action Button (Simpan Perubahan) ---
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
            onPressed: _simpanCheckup,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orangeAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Simpan Perubahan',
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
