import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/controllers/org_controller.dart';
import '../../../../app/routes/app_pages.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
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

  double _parallax(double base, double factor) {
    return base - _scrollOffset * factor;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrgController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(() {
          if (c.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // ===== HEADER GRADIENT =====
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _blendColor(const Color(0xFF009688), const Color(0xFF004D40)),
                      _blendColor(const Color(0xFF4DB6AC), const Color(0xFF00796B)),
                      _blendColor(const Color(0xFF80CBC4), const Color(0xFF26A69A)),
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
                    const SizedBox(height: 16),

                    // ===== HEADER ATAS =====
                    Transform.translate(
                      offset: Offset(0, _parallax(0, 0.3)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "HMIF",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, _parallax(0, 0.2)),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage("assets/images/hmif.jpg"),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== KARTU KABINET =====
                    Transform.translate(
                      offset: Offset(0, _parallax(0, 0.1)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _blendColor(Colors.white, Colors.teal.shade50),
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
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage("assets/images/arunika.jpg"),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: _blendColor(Colors.teal, Colors.teal.shade700),
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "KABINET ARUNIKA 2025",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00695C),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Himpunan Mahasiswa Informatika\nUniversitas Muhammadiyah Malang",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
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
                          onTap: () => Get.toNamed(Routes.PROGRAMKERJA),
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
                            if (c.agendaList.isEmpty) {
                              Get.snackbar(
                                "Info",
                                "Belum ada agenda untuk absensi",
                                snackPosition: SnackPosition.BOTTOM,
                              );
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
                          icon: Icons.photo_library_outlined,
                          label: 'Dokumentasi',
                          color: Colors.pinkAccent.shade100,
                          onTap: () => Get.toNamed(Routes.DOKUMENTASI),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Informasi & Pengumuman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.campaign_outlined,
                              color: Colors.orange, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Rapat koordinasi antar divisi akan dilaksanakan Sabtu, 26 Oktober 2025 pukul 09.00 di ruang B101.",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Kegiatan Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _activityCard(
                              "assets/images/kegiatan1.jpg", "Rapat Bulanan"),
                          _activityCard("assets/images/kegiatan2.jpg",
                              "Pelatihan Kepemimpinan"),
                          _activityCard(
                              "assets/images/kegiatan3.jpg", "Bakti Sosial Desa"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 70),
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
              textAlign: TextAlign.center,
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

  Widget _activityCard(String imagePath, String title) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Agenda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.HOME);
              break;
            case 1:
              Get.toNamed(Routes.NOTIFIKASI);
              break;
            case 2:
              Get.toNamed(Routes.AGENDA_ORGANISASI);
              break;
            case 3:
              Get.toNamed(Routes.STRUKTUR);
              break;
          }
        },
      ),
    );
  }
}
