import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/org_controller.dart';
import 'package:orgtrack/app/ui/keuangan/controllers/keuangan_controller.dart';
import '../../../../app/routes/app_pages.dart';
import 'dart:ui';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    // ⬇️ FIX ERROR ORGCONTROLLER NOT FOUND
    Get.put(OrgController());
    Get.put(KeuanganController());

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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

  double _parallax(double base, double factor) {
    return base - _scrollOffset * factor;
  }

  double _headerOpacity() {
    return (1 - _scrollOffset / 200).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrgController>();
    final keu = Get.find<KeuanganController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(() {
          // ⬇️ FIX: ganti loading → loadingBidang
          if (c.loadingBidang.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
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
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // === HEADER ===
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _headerOpacity(),
                      child: _header(),
                    ),

                    const SizedBox(height: 20),
                    _cabinetCard(),

                    const SizedBox(height: 30),

                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004D40)),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _menuButton(
                          icon: Icons.assignment,
                          label: 'Program Kerja',
                          color: Colors.teal.shade600,
                          onTap: () => Get.toNamed(Routes.Bidang),
                        ),
                        _menuButton(
                          icon: Icons.event,
                          label: 'Agenda',
                          color: Colors.cyan.shade600,
                          onTap: () => Get.toNamed(Routes.AGENDA_ORGANISASI),
                        ),
                        _menuButton(
                          icon: Icons.check_circle_outline,
                          label: 'Absensi',
                          color: Colors.green.shade600,
                          onTap: () {
                            // ⬇️ FIX: agendaList → bidangList (contoh)
                            if (c.bidangList.isEmpty) {
                              Get.snackbar(
                                  "Info", "Belum ada agenda untuk absensi",
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            Get.toNamed(Routes.ATTENDANCE_AGENDA);
                          },
                        ),
                        _menuButton(
                          icon: Icons.account_tree_outlined,
                          label: 'Struktur',
                          color: Colors.teal,
                          onTap: () => Get.toNamed(Routes.STRUKTUR),
                        ),
                        _menuButton(
                          icon: Icons.flag_rounded,
                          label: 'Visi & Misi',
                          color: Colors.deepOrange.shade400,
                          onTap: () => Get.toNamed(Routes.VISI_MISI),
                        ),
                        _menuButton(
                          icon: Icons.bar_chart,
                          label: 'Laporan',
                          color: Colors.indigo.shade400,
                          onTap: () => Get.toNamed(Routes.LAPORAN),
                        ),
                        _menuButton(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Keuangan',
                          color: Colors.orange.shade700,
                          onTap: () => Get.toNamed(Routes.KEUANGAN),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // HEADER (dipisah biar rapi)
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "HMIF",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        )
      ],
    );
  }

  // KABINET CARD
  Widget _cabinetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          const Expanded(
            child: Text(
              "KABINET ARUNIKA 2025\nHimpunan Mahasiswa Informatika\nUniversitas Muhammadiyah Malang",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  // MENU BUTTON
  Widget _menuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAV
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal.shade700,
      unselectedItemColor: Colors.grey.shade500,
      onTap: (index) {
        if (index == 3) {
          Get.toNamed(Routes.PROFILE);
        } else if (index == 2) {
          Get.toNamed(Routes.AGENDA_ORGANISASI);
        } else if (index == 1) {
          Get.snackbar("Info", "Notifikasi belum tersedia");
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Notifikasi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: "Agenda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
