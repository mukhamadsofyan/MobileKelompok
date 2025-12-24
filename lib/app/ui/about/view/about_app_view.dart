import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/theme_controller.dart';

class AboutAppView extends StatelessWidget {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).colorScheme.background;
    final text = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ================= HEADER =================
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF00332E), Color(0xFF002A26)]
                    : const [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                        Color(0xFF80CBC4),
                      ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),

          // ================= CONTENT =================
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 180, 20, 40),
            child: Column(
              children: [
                // ---------- LOGO ----------
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/hmif.jpg",
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "OrgTrack",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black45),
                  ),
                  child: Text(
                    "Versi 1.0.0",
                    style: GoogleFonts.inter(
                      color: Colors.black45,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Tentang OrgTrack", text),
                      Text(
                        "OrgTrack adalah aplikasi manajemen organisasi mahasiswa "
                        "yang dirancang untuk memudahkan pengelolaan agenda, absensi, "
                        "program kerja, dan informasi organisasi secara terpusat, "
                        "modern, dan real-time.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: text.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Fitur Utama", text),
                      _bullet("Manajemen agenda & program kerja"),
                      _bullet("Absensi kegiatan organisasi"),
                      _bullet("Notifikasi real-time"),
                      _bullet("Manajemen struktur organisasi"),
                      _bullet("Laporan & dokumentasi"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Dikembangkan Oleh", text),
                      Text(
                        "Himpunan Mahasiswa Informatika\n"
                        "Universitas Muhammadiyah Malang",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: text.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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

          // ================= APP BAR (PALING ATAS) =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(
                      Icons.arrow_back_ios_new_rounded,
                      () => Get.back(),
                    ),
                    Text(
                      "Tentang Aplikasi",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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

  // ================= COMPONENTS =================

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18, height: 1.3)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
