import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sahabat_rs/screens/penjadwalan/sajad-home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sahabat_rs/screens/Penjadwalan/jadwal.dart';

// PERBAIKAN: Import halaman ChatPages (Daftar Pesan)
import 'package:sahabat_rs/screens/chat/chat-pages.dart';

import '../pengantaran-darurat/sadar_pemesanan.dart';
import '../pendampingan/pilih_kendaraan.dart';

// STUB / Placeholder agar tidak error
class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Halaman Riwayat")));
}

class HalamanUser extends StatefulWidget {
  const HalamanUser({super.key});

  @override
  State<HalamanUser> createState() => _HalamanUserState();
}

class _HalamanUserState extends State<HalamanUser> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_currentIndex) {
      case 0:
        body = const _BerandaSection();
        break;
      case 1:
        body = const RiwayatPage();
        break;
      case 2:
        // PERBAIKAN: Panggil ChatPages() untuk menampilkan daftar chat
        body = const ChatPages();
        break;
      case 3:
      default:
        body = const _PlaceholderSection(
          title: 'Profil',
          description:
              'Halaman Profil akan berisi data pengguna dan pengaturan akun.',
        );
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(child: body),
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ... (Sisa kode ke bawah sama seperti sebelumnya)
/// ======================
/// BERANDA (FITUR UTAMA)
/// ======================
class _BerandaSection extends StatelessWidget {
  const _BerandaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderBeranda(),
            SizedBox(height: 16),
            _SectionKategoriLayanan(),
            SizedBox(height: 16),
            _SectionMedicalCheckup(),
            SizedBox(height: 20),
            _SectionLayananLain(),
            SizedBox(height: 16),
            _SectionJadwal(),
          ],
        ),
      ),
    );
  }
}

/// HEADER: ungu + search bar + alamat expandable
class _HeaderBeranda extends StatefulWidget {
  const _HeaderBeranda();

  @override
  State<_HeaderBeranda> createState() => _HeaderBerandaState();
}

class _HeaderBerandaState extends State<_HeaderBeranda> {
  bool _isAddressExpanded = false;

  String? _userName;
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      String? name;

      if (user != null) {
        final meta = user.userMetadata;
        if (meta != null &&
            (meta['name'] != null || meta['full_name'] != null)) {
          name = (meta['name'] ?? meta['full_name']) as String?;
        }

        if (name == null) {
          final data = await client
              .from('pengguna')
              .select('name')
              .eq('id_pengguna', user.id)
              .maybeSingle();

          if (data != null) {
            name = data['name'] as String?;
          }
        }

        name ??= user.email?.split('@').first;
      }

      if (mounted) {
        setState(() {
          _userName = name;
          _loadingName = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userName = null;
          _loadingName = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const fullAddress = 'Jl. Teknik Komputer V no 187, Surabaya';

    final displayName = _loadingName
        ? '...'
        : (_userName != null && _userName!.isNotEmpty
            ? _userName!
            : 'Pengguna');

    return SizedBox(
      height: 185,
      child: Stack(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5E63E5),
                  Color(0xFF6E7BEE),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/ic_user.png',
                      fit: BoxFit.cover,
                      height: 44,
                      width: 44,
                      errorBuilder: (ctx, err, stack) =>
                          Icon(Icons.person, color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, $displayName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddressExpanded = !_isAddressExpanded;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                fullAddress,
                                maxLines: _isAddressExpanded ? 2 : 1,
                                overflow: _isAddressExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isAddressExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Image.asset(
                    'assets/images/ic_bell.png',
                    width: 26,
                    height: 26,
                    color: const Color(0xFFFFC63A),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFFFFC63A),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // search bar + filter
          Positioned(
            left: 20,
            right: 20,
            top: 112,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFFBDC3C7),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cari',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFBDC3C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFAA2B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// KATEGORI LAYANAN
class _SectionKategoriLayanan extends StatelessWidget {
  const _SectionKategoriLayanan();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Kategori Layanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _KategoriCard(
                  title: 'Pesan Pendamping',
                  gradientColors: [Color(0xFF5D79FF), Color(0xFF4C64F0)],
                  assetName: 'assets/images/pesanpendamping.png',
                  isEmergency: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _KategoriCard(
                  title: 'Darurat',
                  gradientColors: [Color(0xFFFFC63A), Color(0xFFFF8A45)],
                  assetName: 'assets/images/card_darurat.png',
                  isEmergency: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KategoriCard extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final String assetName;
  final bool isEmergency;

  const _KategoriCard({
    required this.title,
    required this.gradientColors,
    required this.assetName,
    required this.isEmergency,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.02,
      child: GestureDetector(
        onTap: () {
          if (isEmergency) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SadarPemesan()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PilihKendaraanPage(),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              assetName,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
      ),
    );
  }
}

/// SECTION MEDICAL CHECK-UP
class _SectionMedicalCheckup extends StatelessWidget {
  const _SectionMedicalCheckup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFE7F3FF),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Check-Up jadi\nmudah dan nyaman',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {},
                    child: const Text('Pesan Sekarang!',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  'assets/images/card_medical_checkup.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LAYANAN LAIN
class _SectionLayananLain extends StatelessWidget {
  const _SectionLayananLain();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Lain',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SajadHomePage()),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/ic_jadwal.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Jadwal',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              _LayananLainItem(
                label: 'Pelacakan',
                assetPath: 'assets/images/ic_pelacakan.png',
                onTap: () {
                  Navigator.of(context).pushNamed('/salacak');
                },
              ),
              const _LayananLainItem(
                label: 'Lainnya',
                assetPath: 'assets/images/ic_lainnya.png',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayananLainItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final VoidCallback? onTap;

  const _LayananLainItem(
      {required this.label, required this.assetPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// JADWAL CHECK-UP TERDEKAT (SUDAH DIPERBAIKI)
class _SectionJadwal extends StatelessWidget {
  const _SectionJadwal();

  // Fungsi fetch data asli dari Supabase
  Future<List<Map<String, dynamic>>> _fetchUpcomingCheckups() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Ambil 2 jadwal terdekat mulai dari hari ini
      final response = await supabase
          .from('checkup')
          .select('tanggal, kegiatan, lokasi')
          .eq('id_pengguna', user.id)
          .gte('tanggal', today)
          .order('tanggal', ascending: true)
          .limit(2);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching home checkups: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Jadwal Medical Check-Up Terdekat',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JadwalPage()),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFAA2B),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchUpcomingCheckups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: Text("Gagal memuat jadwal",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12))),
                  );
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "Belum ada jadwal check-up terdekat",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  );
                }

                // Render list jadwal
                return Column(
                  children: List.generate(data.length, (index) {
                    final item = data[index];
                    final date = DateTime.parse(item['tanggal']);
                    final formattedDate =
                        DateFormat('dd MMMM yyyy', 'id_ID').format(date);
                    final deskripsi = "${item['kegiatan']} - ${item['lokasi']}";

                    return Column(
                      children: [
                        _JadwalRow(
                          tanggal: formattedDate,
                          deskripsi: deskripsi,
                        ),
                        if (index < data.length - 1)
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JadwalRow extends StatelessWidget {
  final String tanggal;
  final String deskripsi;

  const _JadwalRow({required this.tanggal, required this.deskripsi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: Color(0xFFFFC63A), shape: BoxShape.circle),
            child:
                const Icon(Icons.event_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tanggal,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(deskripsi,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF7F8C8D))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  final String title;
  final String description;
  const _PlaceholderSection({required this.title, required this.description});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey))
      ]));
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF4C4F99),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: onTap),
          _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.history_rounded,
              label: 'Riwayat',
              onTap: onTap),
          _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Pesan',
              onTap: onTap),
          _NavItem(
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;
  const _NavItem(
      {required this.index,
      required this.currentIndex,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (selected)
          Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFAA2B), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22))
        else
          Icon(icon, color: const Color(0xFFE0E0E0), size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFFFFAA2B)
                    : const Color(0xFFE0E0E0))),
      ]),
    );
  }
}
