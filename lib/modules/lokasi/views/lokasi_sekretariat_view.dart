import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';

import '../controllers/lokasi_sekretariat_controller.dart';

class LokasiSekretariatView extends StatelessWidget {
  const LokasiSekretariatView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LokasiSekretariatController());
    final themeC = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // ================= HEADER GRADIENT =================
          Container(
            height: 260,
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

          // ================= MAP CARD =================
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: c.umm,
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'orgtrack.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: c.umm,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 400, bottom: 140),
            child: Column(
              children: [
                // ================= INFO CARD =================
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
                      _infoRow(
                        Icons.business,
                        "Lokasi",
                        "Sekretariat HMIF UMM",
                      ),
                      const SizedBox(height: 16),
                      _infoRow(
                        Icons.location_city,
                        "Alamat",
                        "Jl. Raya Tlogomas No.246, Malang",
                      ),
                      const SizedBox(height: 16),
                      _infoRow(
                        Icons.map,
                        "Koordinat",
                        "-7.921350 , 112.596130",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= BUTTON =================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: c.openMaps,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Buka di Google Maps",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= TOP BAR (BACK + TOGGLE) =================
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
                      "Lokasi Sekretariat",
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

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
