import 'package:flutter/material.dart';

class SetLokasiPage extends StatefulWidget {
  final bool isJemput; 
  const SetLokasiPage({super.key, required this.isJemput});

  @override
  State<SetLokasiPage> createState() => _SetLokasiPageState();
}

class _SetLokasiPageState extends State<SetLokasiPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // DATA JEMPUT (DUMMY TAPI NAMANYA BENERAN)
  final List<Map<String, String>> _dataJemput = [
    {"title": "Institut Teknologi Sepuluh Nopember", "address": "Kampus ITS Sukolilo, Surabaya"},
    {"title": "Gedung Rektorat ITS", "address": "Jl. Kertajaya Indah, Surabaya"},
    {"title": "Departemen Sistem Informasi ITS", "address": "Jl. Raya ITS, Sukolilo"},
    {"title": "Asrama Mahasiswa ITS", "address": "Jl. Teknik Arsitektur, Surabaya"},
    {"title": "Kosan Keputih Permai", "address": "Jl. Keputih Tegal No. 10"},
    {"title": "Gebang Lor", "address": "Jl. Gebang Lor No. 55"},
    {"title": "Pakuwon City Mall", "address": "Jl. Kejawan Putih Tambak"},
  ];

  final List<Map<String, String>> _dataRS = [
    {"title": "RS Dr. Soetomo", "address": "Jl. Mayjen Prof. Dr. Moestopo No. 6-8"},
    {"title": "RS Universitas Airlangga", "address": "Kampus C Unair, Mulyorejo"},
    {"title": "RS Haji Surabaya", "address": "Jl. Manyar Kertoadi"},
    {"title": "RS Onkologi Surabaya", "address": "Jl. Arief Rahman Hakim No. 180"},
    {"title": "RS Premier Surabaya", "address": "Jl. Nginden Intan Barat"},
    {"title": "Medical Center ITS", "address": "Jl. Raya ITS (Dalam Kampus)"},
    {"title": "RS Siloam Surabaya", "address": "Jl. Raya Gubeng No. 70"},
  ];

  List<Map<String, String>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.isJemput ? _dataJemput : _dataRS;
  }

  void _runFilter(String keyword) {
    List<Map<String, String>> results = [];
    List<Map<String, String>> sourceData = widget.isJemput ? _dataJemput : _dataRS;

    if (keyword.isEmpty) {
      results = sourceData;
    } else {
      results = sourceData
          .where((item) =>
              item["title"]!.toLowerCase().contains(keyword.toLowerCase()) || 
              item["address"]!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredList = results;
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isJemput ? "Pilih Lokasi Jemput" : "Pilih Faskes Tujuan",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                icon: Icon(
                  widget.isJemput ? Icons.location_on : Icons.local_hospital,
                  color: widget.isJemput ? Colors.orange : Colors.indigo,
                ),
                hintText: widget.isJemput ? "Cari alamat, kampus, kosan..." : "Cari nama rumah sakit...",
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _runFilter("");
                      },
                    )
                  : null,
              ),
            ),
          ),

          // LOKASI SAAT INI (Fixed: Teksnya sopan)
          if (widget.isJemput && _searchController.text.isEmpty)
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                  title: const Text("Gunakan Lokasi Saat Ini", style: TextStyle(fontWeight: FontWeight.bold)),
                  // SUDAH DIHAPUS KATA DUMMY-NYA
                  subtitle: const Text("Jl. Teknik Komputer, Kampus ITS", style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context, "Lokasi Saat Ini");
                  },
                ),
                const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
              ],
            ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              _searchController.text.isEmpty ? "Rekomendasi Lokasi" : "Hasil Pencarian",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: _filteredList.isEmpty 
            ? Center(child: Text("Lokasi tidak ditemukan", style: TextStyle(color: Colors.grey[400])))
            : ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final item = _filteredList[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.grey[400]),
                      title: Text(item["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item["address"]!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      onTap: () {
                        Navigator.pop(context, item["title"]);
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}