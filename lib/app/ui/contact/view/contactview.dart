import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/theme_controller.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // ================= HEADER =================
          Container(
            height: 240,
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
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 40),
            child: Column(
              children: [
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hubungi Kami",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Silakan hubungi kami melalui kontak resmi dan media sosial berikut.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: text.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================= CONTACT INFO =================
                _card(
                  context,
                  child: Column(
                    children: [
                      _contactItem(
                        icon: Icons.email_outlined,
                        title: "Email",
                        value: "hmif@umm.ac.id",
                        textColor: text,
                      ),
                      _contactItem(
                        icon: Icons.phone_outlined,
                        title: "Telepon",
                        value: "+62 812-3456-7890",
                        textColor: text,
                      ),
                      _contactItem(
                        icon: Icons.location_on_outlined,
                        title: "Alamat",
                        value:
                            "Fakultas Teknik\nUniversitas Muhammadiyah Malang",
                        textColor: text,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================= SOCIAL MEDIA GRID =================
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Media Sosial",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _socialGridItem(
                            icon: Icons.camera_alt,
                            label: "Instagram",
                            value: "@hmif_umm",
                          ),
                          _socialGridItem(
                            icon: Icons.music_note,
                            label: "TikTok",
                            value: "@hmif.umm",
                          ),
                          _socialGridItem(
                            icon: Icons.alternate_email,
                            label: "X (Twitter)",
                            value: "@hmif_umm",
                          ),
                          _socialGridItem(
                            icon: Icons.ondemand_video,
                            label: "YouTube",
                            value: "HMIF UMM",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "© 2025 HMIF UMM",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // ================= APP BAR =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(
                      Icons.arrow_back_ios_new_rounded,
                      () => Get.back(),
                    ),
                    Text(
                      "Kontak Kami",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _circleBtn(
                      themeC.isDark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      () => themeC.toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMPONENT =================

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialGridItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.teal.shade700),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

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
}
