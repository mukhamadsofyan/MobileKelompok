import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/profile_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final c = Get.put(ProfileController());
  final auth = Get.find<AuthController>();
  final themeC = Get.find<ThemeController>();

  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // ================= HEADER =================
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeC.isDark
                    ? const [Color(0xFF00332E), Color(0xFF002A26)]
                    : const [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                        Color(0xFF80CBC4),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
          ),

          // ================= CONTENT =================
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 140, bottom: 140),
                child: Column(
                  children: [
                    // ================= PROFILE CARD =================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Obx(() {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/images/hmif.jpg",
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              c.email.value,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.role.value.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // ================= MENU CARD =================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _sectionTitle("INFORMASI", text),
                          _menuItem(
                            icon: Icons.workspace_premium_outlined,
                            title: "Benefit Masuk HMIF",
                            onTap: () => Get.toNamed(Routes.BENEFIT_HMIF),
                            textColor: text,
                          ),

                          _menuItem(
                            icon: Icons.location_on_outlined,
                            title: "Lokasi Sekretariat UMM",
                            onTap: () => Get.toNamed(Routes.LOKASI_SEKRETARIAT),
                            textColor: text,
                          ),
                          _menuItem(
                            icon: Icons.contact_mail_outlined,
                            title: "Kontak Kami",
                            onTap: () => Get.toNamed(Routes.CONTACT),
                            textColor: text,
                          ),

                          _menuItem(
                            icon: Icons.info_outline,
                            title: "Tentang Aplikasi",
                            onTap: () => Get.toNamed(Routes.ABOUT),
                            textColor: text,
                          ),
                          const Divider(height: 28),
                          InkWell(
                            onTap: auth.logout,
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Logout",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= APP BAR (PALING ATAS) =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(
                      Icons.arrow_back_ios_new_rounded,
                      () => Get.back(),
                    ),
                    Text(
                      "Profil",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _circleBtn(
                      themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                      () => themeC.toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= FOOTER =================
      bottomNavigationBar: _modernFooter(context, isDark),
    );
  }

  // ================= FOOTER =================
  Widget _modernFooter(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFF009688),
                  Color(0xFF4DB6AC),
                  Color(0xFF80CBC4),
                ],
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
        if (index == 0) Get.offAllNamed(Routes.HOME);
        if (index == 1) Get.offAllNamed(Routes.AGENDA_ORGANISASI);
        if (index == 2) Get.offAllNamed(Routes.NOTIFIKASI);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: active ? Colors.white : Colors.white70),
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

  // ================= UTIL =================
  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.teal.shade700),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: textColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
