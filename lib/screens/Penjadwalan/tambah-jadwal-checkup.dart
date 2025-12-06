import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'package:sahabat_rs/models/jadwal_checkup_detail.dart'; // Sesuaikan path model
import 'package:sahabat_rs/services/jadwal_service.dart'; // Sesuaikan path service

// --- Konstanta Warna ---
// Orange/Aksen Color
const Color _orangeAksen = Color(0xFFF6A230);
// Warna latar belakang input field
const Color _inputBgColor = Color(0xFFF8F8F6);
// Warna teks dalam input
const Color _inputTextColor = Color(0xFF333333);
// Warna icon dan teks abu-abu terang
const Color _greyIconColor = Color(0xFF9E9E9E);

// --- Widget Kustom untuk Input Field (TIDAK BERUBAH) ---
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

// --- Halaman Tambah Jadwal Check-Up ---
class TambahJadwalCheckupPage extends StatefulWidget {
  const TambahJadwalCheckupPage({Key? key}) : super(key: key);

  @override
  State<TambahJadwalCheckupPage> createState() =>
      _TambahJadwalCheckupPageState();
}

class _TambahJadwalCheckupPageState extends State<TambahJadwalCheckupPage> {
  // State untuk data form
  DateTime? _selectedDate;
  // Default waktu notifikasi (diatur ke 10:00 AM)
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  // Controllers untuk input text (Nilai awal diatur secara dummy)
  final TextEditingController _dateController = TextEditingController(
    text: 'Date',
  );
  final TextEditingController _lokasiController = TextEditingController(
    text: 'Rumah Sakit / Klinik',
  );
  final TextEditingController _kegiatanController = TextEditingController(
    text: 'Contoh: Kontrol Dokter THT',
  );
  final TextEditingController _kondisiController = TextEditingController(
    text: 'Contoh: Pengguna kursi roda, alergi obat',
  );

  // Controller untuk waktu
  final TextEditingController _timeController = TextEditingController();

  // Flag untuk inisialisasi controller waktu
  bool _isTimeControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Hapus pemanggilan _updateTimeController() dari sini
  }

  // Panggil pemformatan yang menggunakan context di sini (lifecycle method yang aman)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTimeControllerInitialized) {
      _updateTimeController(context); // Panggil dengan context
      _isTimeControllerInitialized = true;
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

  // --- Fungsi Picker ---

  // 1. Pemilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        // Memformat tanggal ke format lokal Indonesia
        _dateController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(_selectedDate!);
      });
    }
  }

  // 2. Pemilih Waktu (Notifikasi)
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
        _updateTimeController(context); // Panggil dengan context
      });
    }
  }

  // DIPERBAIKI: Menerima context sebagai parameter
  void _updateTimeController(BuildContext context) {
    setState(() {
      _timeController.text = _selectedTime.format(context);
    });
  }

  // --- Fungsi Simpan ---
  void _simpanCheckup() async {
    if (_selectedDate == null ||
        _lokasiController.text.isEmpty ||
        _kegiatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal, Lokasi, dan Kegiatan wajib diisi.'),
        ),
      );
      return;
    }

    // Asumsi: Logic penyimpanan data ke database di sini

    // Setelah selesai, kembali ke halaman sebelumnya
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
                hintText: '10:00 AM',
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
    // Memanggil _updateTimeController di sini untuk memastikan controller memiliki nilai awal
    if (!_isTimeControllerInitialized) {
      _updateTimeController(context);
      _isTimeControllerInitialized = true;
    }

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
          'Tambahkan Jadwal Checkup',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(); // Batal kembali ke halaman sebelumnya
            },
            child: const Text(
              'simpan',
              style: TextStyle(
                color: Color.fromARGB(
                  255,
                  0,
                  0,
                  0,
                ), // Warna merah untuk tombol Batal
                fontWeight: FontWeight.w600,
              ),
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
              hintText: 'Date',
            ),
            const SizedBox(height: 20),

            // 2. Lokasi
            _buildRoundedInputField(
              label: 'Lokasi',
              controller: _lokasiController,
              iconData: Icons.book_outlined,
              hintText: 'lokasi',
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
            onPressed: _simpanCheckup,
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
}
