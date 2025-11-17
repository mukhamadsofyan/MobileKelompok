import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';

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
  late Animation<double> _fadeContent;
  late Animation<Offset> _slideContent;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeContent = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideContent = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
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
    final bgColor = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,

      body: Stack(
        children: [
          // ================= GRADIENT HEADER =================
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeC.isDark
                    ? const [
                        Color(0xFF00332E),
                        Color(0xFF002A26),
                      ]
                    : const [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                        Color(0xFF80CBC4),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          // ================= HEADER BAR =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // TITLE
                  Text(
                    "Profil",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),

                  // THEME TOGGLE
                  GestureDetector(
                    onTap: () => themeC.toggleTheme(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= MAIN CONTENT =================
          SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeContent,
              child: SlideTransition(
                position: _slideContent,
                child: Column(
                  children: [
                    const SizedBox(height: 110),

                    // ---------- FOTO PROFIL ----------
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/hmif.jpg",
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------- EMAIL + ROLE ----------
                    Obx(() {
                      return Column(
                        children: [
                          Text(
                            c.email.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              c.role.value.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 35),

                    // ================= GLASS CARD =================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 26),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          _sectionTitle("Akun", textColor),

                          _menuItem(
                            icon: Icons.person_outline,
                            title: "Edit Profil",
                            colorText: textColor,
                            onTap: () {
                              Get.snackbar(
                                "Info",
                                "Fitur edit profil akan ditambahkan.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.teal.shade50,
                                colorText: Colors.teal.shade900,
                              );
                            },
                          ),

                          _menuItem(
                            icon: Icons.lock_outline,
                            title: "Keamanan",
                            colorText: textColor,
                            onTap: () {},
                          ),

                          _menuItem(
                            icon: Icons.notifications_none,
                            title: "Notifikasi",
                            colorText: textColor,
                            onTap: () {},
                          ),

                          _menuItem(
                            icon: Icons.info_outline,
                            title: "Tentang Aplikasi",
                            colorText: textColor,
                            onTap: () {},
                          ),

                          const SizedBox(height: 14),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 14),

                          // LOGOUT
                          GestureDetector(
                            onTap: () => auth.logout(),
                            child: Row(
                              children: [
                                const Icon(Icons.logout,
                                    color: Colors.redAccent, size: 27),
                                const SizedBox(width: 14),
                                Text(
                                  "Logout",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ================= MENU ITEM =================
  Widget _menuItem({
    required IconData icon,
    required String title,
    required Color colorText,
    required VoidCallback onTap,
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
                color: Colors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.teal.shade700, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: colorText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 17, color: colorText.withOpacity(0.45)),
          ],
        ),
      ),
    );
  }
}
