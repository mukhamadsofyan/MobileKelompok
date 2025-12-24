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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(OrgController());
    Get.put(KeuanganController());

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  Color _blendColor(Color start, Color end) {
    final t = (_scrollOffset / 220).clamp(0.0, 1.0);
    return Color.lerp(start, end, t)!;
  }

  BorderRadius _dynamicBorderRadius() {
    final r = (40 - _scrollOffset / 5).clamp(0.0, 40.0);
    return BorderRadius.only(
      bottomLeft: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );
  }

  double _dynamicHeaderHeight() {
    const minH = 100.0;
    const maxH = 220.0;
    final t = (_scrollOffset / 250).clamp(0.0, 1.0);
    return maxH - (maxH - minH) * t;
  }

  double _headerOpacity() => (1 - _scrollOffset / 200).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrgController>();
    final themeC = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // ================= HEADER =================
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

              // ================= CONTENT =================
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
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ],
          );
        }),
      ),

      // 🔥 FOOTER KONDISIONAL
      bottomNavigationBar: _modernFooter(context, isDark),
    );
  }

  // ================= HEADER ROW =================
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
                color: Colors.white,
              ),
              onPressed: themeC.toggleTheme,
            ),
          ],
        ),
      ],
    );
  }

  // ================= CABINET CARD =================
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
          const Expanded(
            child: Text(
              "KABINET ARUNIKA 2025\nHimpunan Mahasiswa Informatika\nUniversitas Muhammadiyah Malang",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU GRID =================
  Widget _menuGrid(BuildContext context, OrgController c) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _menuButton(context, Icons.assignment, 'Program Kerja', Colors.teal,
            () => Get.toNamed(Routes.BIDANG)),
        _menuButton(context, Icons.event, 'Agenda', Colors.cyan,
            () => Get.toNamed(Routes.AGENDA_ORGANISASI)),
        _menuButton(context, Icons.check_circle_outline, 'Absensi', Colors.green,
            () => Get.toNamed(Routes.ATTENDANCE_AGENDA)),
        _menuButton(context, Icons.account_tree_outlined, 'Struktur', Colors.teal,
            () => Get.toNamed(Routes.STRUKTUR)),
        _menuButton(context, Icons.flag, 'Visi & Misi', Colors.deepOrange,
            () => Get.toNamed(Routes.VISI_MISI)),
        _menuButton(context, Icons.bar_chart, 'Laporan', Colors.indigo,
            () => Get.toNamed(Routes.LAPORAN)),
        _menuButton(context, Icons.account_balance_wallet, 'Keuangan',
            Colors.orange, () => Get.toNamed(Routes.KEUANGAN)),
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
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _modernFooter(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        // 🌙 DARK MODE → WARNA LAMA
        color: isDark ? const Color(0xFF1E1E1E) : null,

        // 🌞 LIGHT MODE → GRADIENT HEADER
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF009688),
                  Color(0xFF4DB6AC),
                  Color(0xFF80CBC4),
                ],
              ),

        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.home, "Beranda", 0),
          _footerItem(Icons.event, "Agenda", 1),
          _footerItem(Icons.notifications, "Notifikasi", 2),
          _footerItem(Icons.person, "Profil", 3),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) Get.toNamed(Routes.AGENDA_ORGANISASI);
        if (index == 2) Get.toNamed(Routes.NOTIFIKASI);
        if (index == 3) Get.toNamed(Routes.PROFILE);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 26,
              color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
