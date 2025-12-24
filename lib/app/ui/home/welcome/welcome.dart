import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController slideController;

  late Animation<double> fadeHeader;
  late Animation<Offset> slideCard;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeHeader = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOutQuart,
    );

    slideCard = Tween<Offset>(
      begin: const Offset(0, 0.32),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideController,
        curve: Curves.easeOutBack,
      ),
    );

    fadeController.forward();
    slideController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB5F5F0),
              Color(0xFF7EE7E0),
              Color(0xFF35CCBE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),

            // HEADER IMAGE
            FadeTransition(
              opacity: fadeHeader,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Image.asset(
                    "assets/images/arunobg.png",
                    height: 230,
                  ),
                ),
              ),
            ),

            // CARD PUTIH
            Expanded(
              child: SlideTransition(
                position: slideCard,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 35,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    children: [
                      // TITLE
                      Text(
                        "Kabinet Arunika",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00A6AF),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // SUBTITLE
                      Text(
                        "Himpunan Mahasiswa Informatika\nUniversitas Muhammadiyah Malang",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // SMALL DESCRIPTION
                      Text(
                        "Bersama membangun ruang belajar,\nkolaborasi, dan kontribusi berkelanjutan.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black54,
                        ),
                      ),

                      const Spacer(),

                      // INDICATOR / DECORATIVE DOTS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00B8C0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B8C0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          onPressed: () => Get.offAllNamed('/login'),
                          child: const Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white, // ✔ jelas terbaca
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // POWERED BY
                      Text(
                        "Powered by HMIF UMM",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
