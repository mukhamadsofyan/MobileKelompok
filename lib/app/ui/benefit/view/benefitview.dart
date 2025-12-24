import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/theme_controller.dart';

class BenefitHMIFView extends StatelessWidget {
  const BenefitHMIFView({super.key});

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
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 140, bottom: 40),
            child: Column(
              children: [
                // ================= HERO CARD =================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(22),
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Colors.teal.shade600,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Benefit Masuk HMIF",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bergabung dengan HMIF memberikan banyak manfaat untuk "
                        "pengembangan akademik, soft skill, dan relasi profesional.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.6,
                          color: text.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= BENEFIT LIST =================
                _benefitCard(
                  icon: Icons.groups_rounded,
                  title: "Relasi & Networking",
                  desc:
                      "Memperluas relasi dengan mahasiswa, alumni, dan pihak eksternal "
                      "seperti perusahaan serta komunitas IT.",
                  isDark: isDark,
                  text: text,
                ),
                _benefitCard(
                  icon: Icons.school_rounded,
                  title: "Pengembangan Soft Skill",
                  desc:
                      "Melatih kepemimpinan, komunikasi, kerja tim, dan problem solving "
                      "melalui kegiatan organisasi.",
                  isDark: isDark,
                  text: text,
                ),
                _benefitCard(
                  icon: Icons.emoji_events_rounded,
                  title: "Event & Perlombaan",
                  desc:
                      "Kesempatan mengikuti seminar, workshop, dan lomba IT tingkat "
                      "regional maupun nasional.",
                  isDark: isDark,
                  text: text,
                ),
                _benefitCard(
                  icon: Icons.badge_rounded,
                  title: "Sertifikat & Pengalaman",
                  desc:
                      "Mendapatkan sertifikat kepanitiaan dan pengalaman organisasi "
                      "yang berguna untuk CV dan karier.",
                  isDark: isDark,
                  text: text,
                ),
                _benefitCard(
                  icon: Icons.work_outline_rounded,
                  title: "Peluang Karier",
                  desc:
                      "Akses informasi magang, lowongan kerja, serta rekomendasi "
                      "dari relasi internal dan alumni HMIF.",
                  isDark: isDark,
                  text: text,
                ),
              ],
            ),
          ),

          // ================= TOP BAR =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(
                      Icons.arrow_back_ios_new_rounded,
                      () => Get.back(),
                    ),
                    Text(
                      "Benefit HMIF",
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

  // ================= BENEFIT CARD =================
  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
    required Color text,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.teal, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: text.withOpacity(0.75),
                  ),
                ),
              ],
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
}
