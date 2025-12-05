import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final riwayatList = [
      const _RiwayatItemData(
        tanggal: '10 Sep, 11:30',
        namaRs: 'RS Hangtuah',
        status: 'Pendampingan Selesai',
        isDibatalkan: false,
      ),
      const _RiwayatItemData(
        tanggal: '9 Sep, 09:20',
        namaRs: 'RS Unair',
        status: 'Pendampingan Selesai',
        isDibatalkan: false,
      ),
      const _RiwayatItemData(
        tanggal: '8 Sep, 14:50',
        namaRs: 'RS Soetomo',
        status: 'Pendampingan Dibatalkan',
        isDibatalkan: true,
      ),
      const _RiwayatItemData(
        tanggal: '8 Sep, 11:30',
        namaRs: 'RS NU',
        status: 'Pendampingan Selesai',
        isDibatalkan: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, size: 22),
              ),
            ],
          ),
        ),

        // TAB Selesai / Dibatalkan (dummy, belum filter)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: const [
                _SegmentTab(
                  label: 'Selesai',
                  selected: true,
                ),
                _SegmentTab(
                  label: 'Dibatalkan',
                  selected: false,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // LIST RIWAYAT
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: riwayatList.length,
            itemBuilder: (context, index) {
              final item = riwayatList[index];
              return _RiwayatCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _SegmentTab({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFFFF9F1C)
                : const Color(0xFF7F8C8D),
          ),
        ),
      ),
    );
  }
}

class _RiwayatItemData {
  final String tanggal;
  final String namaRs;
  final String status;
  final bool isDibatalkan;

  const _RiwayatItemData({
    required this.tanggal,
    required this.namaRs,
    required this.status,
    required this.isDibatalkan,
  });
}

class _RiwayatCard extends StatelessWidget {
  final _RiwayatItemData item;

  const _RiwayatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isDibatalkan
        ? const Color(0xFFE74C3C)
        : const Color(0xFF27AE60);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon RS / kendaraan (nanti bisa diganti asset Figma)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD56B),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_hospital, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tanggal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF95A5A6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.namaRs,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      item.isDibatalkan
                          ? Icons.cancel_rounded
                          : Icons.check_circle_rounded,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9F1C),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // TODO: sambungkan ke alur "Pesan Lagi"
            },
            child: const Text(
              'Pesan Lagi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
