import 'package:flutter/material.dart';
// UPDATE IMPORT INI (Sesuai nama file baru)
import '../pendampingan/batalkan-pesanan.dart'; 

class PembayaranBerhasilDialog extends StatelessWidget {
  final String namaDriver;

  const PembayaranBerhasilDialog({super.key, required this.namaDriver});

  void _lanjutKeTracking(BuildContext context) {
    Navigator.pop(context); // Tutup Popup
    
    // PINDAH KE HALAMAN "BATALKAN PESANAN" (Waiting Page)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BatalkanPesananPage(namaDriver: namaDriver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (SAMA SEPERTI KODE SEBELUMNYA) ...
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => _lanjutKeTracking(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5C6BC0), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.orange, size: 50),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  "Pembayaran Berhasil",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.orange
                  ),
                ),
                const SizedBox(height: 10),
                
                const Text(
                  "Transaksi kamu sudah berhasil.\nSistem sedang mencarikan driver...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context, String namaDriver) {
  showDialog(
    context: context,
    barrierDismissible: false, 
    barrierColor: Colors.black54, 
    builder: (context) => PembayaranBerhasilDialog(namaDriver: namaDriver),
  );
}