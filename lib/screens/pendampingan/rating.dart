import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final String namaDriver;

  const RatingPage({super.key, required this.namaDriver});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0; // 0 Belum ada bintang
  int _selectedTipIndex = -1; // -1 Belum ada tip yang dipilih
  final TextEditingController _tipController = TextEditingController();

  // Daftar Pilihan Tip
  final List<String> _tipOptions = ["No Tip", "1000", "2000", "3000", "5000", "10000"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange), // Panah orange sesuai gambar
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kasih Nilai Pendamping",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              // Kalau di-close, anggap selesai dan balik ke home
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Teks Atas
              const Text(
                "Pendampingan Anda telah selesai",
                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Strip Total Harga (Ungu Muda)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6), // Warna ungu muda pudar
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Total :", style: TextStyle(color: Colors.black54)),
                    Text("Rp. 120.000", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Avatar Driver
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[50],
                child: Image.asset(
                  "assets/images/profile_placeholder.png", 
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // Pertanyaan Rating
              const Text(
                "Bagaimana Pelayanan Pendamping?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Bintang 5 (Interactive)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating ? Colors.orange : Colors.grey,
                      size: 32,
                    ),
                  );
                }),
              ),
              
              const Text(
                "Umpan balik Anda bersifat anonim",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 30),

              // Pertanyaan Tip
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Apakah Anda ingin memberikan tip untuknya?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Grid Pilihan Tip
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_tipOptions.length, (index) {
                  bool isSelected = _selectedTipIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTipIndex = index;
                        // Kalau pilih preset, textfield custom dikosongin biar ga bingung
                        if (index != 0) { // Index 0 itu 'No Tip'
                           _tipController.text = _tipOptions[index];
                        } else {
                           _tipController.clear();
                        }
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 3, // Bagi 3 kolom
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _tipOptions[index],
                          style: TextStyle(
                            color: isSelected ? Colors.orange : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Input Manual Tip
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Masukkan Nominal", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tipController,
                keyboardType: TextInputType.number,
                onTap: () {
                  // Kalau user ngetik manual, hilangkan seleksi chip di atas
                  setState(() {
                    _selectedTipIndex = -1;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Min. 500",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // LOGIKA KIRIM RATING
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Terima kasih atas penilaian Anda!")),
                    );

                    // RESET KE HOMEPAGE
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    "Kirim",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}