import 'package:flutter/material.dart';
import 'pembayaran-berhasil.dart'; // Import popup sukses

class PembayaranDigitalPage extends StatefulWidget {
  final String namaDriver;     
  final int hargaTransport;    

  const PembayaranDigitalPage({
    super.key,
    required this.namaDriver,
    required this.hargaTransport,
  });

  @override
  State<PembayaranDigitalPage> createState() => _PembayaranDigitalPageState();
}

class _PembayaranDigitalPageState extends State<PembayaranDigitalPage> {
  int _selectedMethod = 1; 
  final int _biayaJasa = 150000;

  @override
  Widget build(BuildContext context) {
    int totalBayar = _biayaJasa + widget.hargaTransport;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pembayaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. RINGKASAN PESANAN (KARTU KUNING) ---
              const Text("Ringkasan Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835), // Kuning
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pendampingan Lansia ke Rumah Sakit",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // Nama Driver
                    Text(widget.namaDriver, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 16),
                    
                    // Rincian
                    _buildSummaryRow("Biaya Pelayanan", _formatRupiah(_biayaJasa)),
                    const SizedBox(height: 4),
                    _buildSummaryRow("Biaya Transportasi", _formatRupiah(widget.hargaTransport)),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Colors.black12),
                    ),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_formatRupiah(totalBayar), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. PILIH METODE PEMBAYARAN ---
              const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF176).withOpacity(0.6), // Kuning Muda
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildPaymentOption(0, "Transfer Bank", "BCA, BNI, MANDIRI, BRI"),
                    const SizedBox(height: 12),
                    _buildPaymentOption(1, "Kartu Debit/Kredit", "Visa, MasterCard"),
                    const SizedBox(height: 12),
                    _buildPaymentOption(2, "E-Wallet", "GoPay, ShopeePay, OVO"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- 3. TOMBOL BAYAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Panggil Popup Sukses
                    showSuccessDialog(context, widget.namaDriver);
                  },
                  child: const Text("Bayar", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              // Tambahan padding bawah biar ga mepet
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPaymentOption(int index, String title, String subtitle) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.green, width: 2) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int number) {
    return "Rp${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}