import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';
import '../controllers/visi_misi_controller.dart';

class VisiMisiView extends StatefulWidget {
  const VisiMisiView({super.key});

  @override
  State<VisiMisiView> createState() => _VisiMisiViewState();
}

class _VisiMisiViewState extends State<VisiMisiView> {
  final themeC = Get.find<ThemeController>();
  final c = Get.find<VisiMisiController>();

  final icons = const [
    Icons.school_rounded,
    Icons.groups_rounded,
    Icons.lightbulb_rounded,
    Icons.public_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
      body: Column(
        children: [
          // ===================== HEADER (SAMA KAYA AGENDA) =====================
          Container(
            padding: const EdgeInsets.only(
              top: 45,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeC.isDark
                    ? const [
                        Color(0xFF00332E),
                        Color(0xFF004D40),
                        Color(0xFF003E39),
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
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // back button bulat (sama kaya agenda)
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const Text(
                      "Visi & Misi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                      ),
                      onPressed: () => themeC.toggleTheme(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // subtitle kecil biar elegan (opsional)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Arah & tujuan organisasi",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================== CONTENT =====================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO ICON
                  Center(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 450),
                      tween: Tween(begin: 0, end: 1),
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            color: themeC.isDark
                                ? Colors.teal.shade200
                                : Colors.teal.shade700,
                            size: 86,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Organisasi Mahasiswa Unggul',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.5,
                              color: themeC.isDark
                                  ? Colors.teal.shade200
                                  : Colors.teal.shade700,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // VISI CARD
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 520),
                    tween: Tween(begin: 0, end: 1),
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.18),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.remove_red_eye_rounded,
                                  color: Colors.teal.shade700,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Visi",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            c.visi,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorText,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // MISI TITLE
                  Row(
                    children: [
                      Icon(Icons.flag_rounded,
                          color: Colors.teal.shade700, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        "Misi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // MISI GRID (BIAR JELAS, ADA BORDER)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: c.misi.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (_, index) {
                      final misi = c.misi[index];
                      final icon = icons[index % icons.length];

                      return TweenAnimationBuilder<double>(
                        duration:
                            Duration(milliseconds: 350 + (index * 90)),
                        tween: Tween(begin: 0, end: 1),
                        builder: (_, v, child) => Opacity(
                          opacity: v,
                          child: Transform.scale(
                            scale: 0.98 + (0.02 * v),
                            child: child,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showMisiDialog(
                            context,
                            title: "Misi ${index + 1}",
                            message: misi,
                            icon: icon,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.teal.shade300.withOpacity(0.65),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      Colors.teal.withOpacity(0.12),
                                  child: Icon(
                                    icon,
                                    color: Colors.teal.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Text(
                                    misi,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: colorText,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMisiDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "misi_dialog",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.12),
                    radius: 32,
                    child: Icon(icon, color: Colors.teal, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 15.5,
                      color: textColor,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(
                        'Tutup',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }
}
