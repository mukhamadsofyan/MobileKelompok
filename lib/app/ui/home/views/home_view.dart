import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/org_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import 'package:orgtrack/app/ui/keuangan/controllers/keuangan_controller.dart';
import '../../../../app/routes/app_pages.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    // Pastikan controller tidak null
    Get.put(OrgController());
    Get.put(KeuanganController());

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Color _blendColor(Color start, Color end) {
    double t = (_scrollOffset / 220).clamp(0.0, 1.0);
    return Color.lerp(start, end, t)!;
  }

  BorderRadius _dynamicBorderRadius() {
    double radius = (40 - _scrollOffset / 5).clamp(0.0, 40.0);
    return BorderRadius.only(
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  double _dynamicHeaderHeight() {
    double minHeight = 100;
    double maxHeight = 220;
    double t = (_scrollOffset / 250).clamp(0.0, 1.0);
    return maxHeight - (maxHeight - minHeight) * t;
  }

  double _headerOpacity() {
    return (1 - _scrollOffset / 200).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrgController>();
    final themeC = Get.find<ThemeController>();

    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: colorBG,
      body: SafeArea(
        child: Obx(() {
          if (c.loadingBidang.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // HEADER BACKGROUND
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _dynamicHeaderHeight(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _blendColor(
                          const Color(0xFF009688), const Color(0xFF004D40)),
                      _blendColor(
                          const Color(0xFF4DB6AC), const Color(0xFF00796B)),
                      _blendColor(
                          const Color(0xFF80CBC4), const Color(0xFF26A69A)),
                    ],
                  ),
                  borderRadius: _dynamicBorderRadius(),
                ),
              ),

              // CONTENT
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _headerOpacity(),
                      child: _header(themeC),
                    ),
                    const SizedBox(height: 20),
                    _cabinetCard(context),
                    const SizedBox(height: 30),
                    Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _menuGrid(context, c),
                    const SizedBox(height: 30),
                    _pengumumanHeader(),
                    const SizedBox(height: 12),
                    _pengumumanList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // HEADER
  Widget _header(ThemeController themeC) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "HMIF",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage("assets/images/hmif.jpg"),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () => themeC.toggleTheme(),
            ),
          ],
        )
      ],
    );
  }

  // CABINET CARD
  Widget _cabinetCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              "assets/images/arunika.jpg",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "KABINET ARUNIKA 2025\nHimpunan Mahasiswa Informatika\nUniversitas Muhammadiyah Malang",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          )
        ],
      ),
    );
  }

  // MENU GRID
  Widget _menuGrid(BuildContext context, OrgController c) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _menuButton(context, Icons.assignment, 'Program Kerja', Colors.teal,
            () {
          Get.toNamed(Routes.BIDANG);
        }),
        _menuButton(context, Icons.event, 'Agenda', Colors.cyan, () {
          Get.toNamed(Routes.AGENDA_ORGANISASI);
        }),
        _menuButton(
            context, Icons.check_circle_outline, 'Absensi', Colors.green, () {
          if (c.bidangList.isEmpty) {
            Get.snackbar("Info", "Belum ada agenda untuk absensi");
            return;
          }
          Get.toNamed(Routes.ATTENDANCE_AGENDA);
        }),
        _menuButton(
            context, Icons.account_tree_outlined, 'Struktur', Colors.teal, () {
          Get.toNamed(Routes.STRUKTUR);
        }),
        _menuButton(context, Icons.flag, 'Visi & Misi', Colors.deepOrange, () {
          Get.toNamed(Routes.VISI_MISI);
        }),
        _menuButton(context, Icons.bar_chart, 'Laporan', Colors.indigo, () {
          Get.toNamed(Routes.LAPORAN);
        }),
        _menuButton(context, Icons.account_balance_wallet_rounded, 'Keuangan',
            Colors.orange, () {
          Get.toNamed(Routes.KEUANGAN);
        }),
        _menuButton(context, Icons.my_location, 'Live Location', Colors.blue,
            () {
          Get.toNamed(Routes.LOKASI);
        }),
      ],
    );
  }

  Widget _menuButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // PENGUMUMAN HEADER
  // ========================================================
  Widget _pengumumanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pengumuman Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.PENGUMUMAN),
          child: const Text("Lihat Semua"),
        ),
      ],
    );
  }

  // ========================================================
  // PENGUMUMAN LIST — Aman dari null
  // ========================================================
  Widget _pengumumanList() {
    final dummy = [
      {
        "title": "Rapat Besar HMIF 2025",
        "date": "28 November 2025",
        "desc": "Seluruh pengurus diwajibkan hadir pada pukul 19.00 WIB."
      },
      {
        "title": "Pengumpulan Laporan Progress",
        "date": "27 November 2025",
        "desc": "Semua bidang wajib mengumpulkan laporan perkembangan."
      },
      {
        "title": "Open Recruitment Panitia",
        "date": "24 November 2025",
        "desc": "Kesempatan bergabung sebagai panitia event besar tahun ini."
      },
    ];

    final limited = dummy.take(3).toList();

    return Column(
      children: limited.map((ann) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.campaign, color: Colors.purple, size: 26),
              ),
              const SizedBox(width: 14),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ann["title"] ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ann["date"] ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ann["desc"] ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  // ========================================================
  // BOTTOM NAVIGATION
  // ========================================================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Colors.teal.shade700,
      unselectedItemColor:
          Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      onTap: (index) {
        if (index == 3) {
          Get.toNamed(Routes.PROFILE);
        } else if (index == 2) {
          Get.toNamed(Routes.AGENDA_ORGANISASI);
        } else if (index == 1) {
          Get.toNamed(Routes.NOTIFIKASI);
          // NOTIFIKASI → ke pengumuman
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: "Notifikasi"),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: "Agenda"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}
