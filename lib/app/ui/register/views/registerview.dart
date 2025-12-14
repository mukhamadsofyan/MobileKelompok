import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  late AnimationController fadeController;
  late AnimationController shakeController;

  late Animation<double> fadeHeader;
  late Animation<Offset> slideCard;
  late Animation<double> shake;

  bool isError = false;
  bool isPasswordVisible = false; // 👁️ toggle untuk lihat password

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeHeader = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );

    slideCard = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    shake = Tween<double>(begin: 0, end: 14)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController);

    fadeController.forward();
  }

  void triggerError() async {
    setState(() => isError = true);
    shakeController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => isError = false);
  }

  @override
  void dispose() {
    fadeController.dispose();
    shakeController.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9DF2EC),
              Color(0xFF5BDDD7),
              Color(0xFF27C2B8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 70),

              FadeTransition(
                opacity: fadeHeader,
                child: Center(
                  child: Image.asset(
                    "assets/images/arunika.jpg",
                    height: 200,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AnimatedBuilder(
                animation: shakeController,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(shake.value * (isError ? 1 : 0), 0),
                    child: child,
                  );
                },

                child: SlideTransition(
                  position: slideCard,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: height - 290,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                "Login",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF00A6AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // EMAIL
                        _inputField(
                          controller: emailC,
                          hint: "Enter your email",
                          icon: Icons.email_outlined,
                          error: isError,
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD + show/hide
                        _inputField(
                          controller: passC,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          obscure: true,
                          error: isError,
                          isPassword: true,
                          togglePassword: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B8C0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: auth.isLoading.value
                                  ? null
                                  : () async {
                                      final email = emailC.text.trim();
                                      final pass = passC.text.trim();

                                      String? validationMsg;

                                      if (email.isEmpty || pass.isEmpty) {
                                        validationMsg =
                                            "Email dan password tidak boleh kosong.";
                                      } else if (!GetUtils.isEmail(email)) {
                                        validationMsg =
                                            "Format email tidak valid.";
                                      } else if (pass.length < 6) {
                                        validationMsg =
                                            "Password minimal 6 karakter.";
                                      }

                                      if (validationMsg != null) {
                                        Get.snackbar(
                                          "Validasi gagal",
                                          validationMsg,
                                          snackPosition:
                                              SnackPosition.TOP,
                                        );
                                        triggerError();
                                        return;
                                      }

                                      bool success =
                                          await auth.register(email, pass);

                                      if (!success) triggerError();
                                    },
                              child: auth.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "SIGN UP",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        }),

                        const SizedBox(height: 30),

                        Center(
                          child: Text(
                            "Or Continue With",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _social("Apple", Icons.apple),
                            const SizedBox(width: 15),
                            _social("Google", Icons.g_mobiledata),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // INPUT FIELD
  // ==========================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool error = false,
    bool isPassword = false,
    VoidCallback? togglePassword,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      decoration: BoxDecoration(
        color: error ? Colors.red.shade50 : const Color(0xFFF0F3F6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: error ? Colors.red.shade300 : Colors.black26,
          width: error ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          Icon(
            icon,
            color: error ? Colors.red.shade400 : Colors.black87,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure && !isPasswordVisible,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),

                // 👁️ Lihat/Sembunyikan password
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: togglePassword,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // SOCIAL LOGIN BUTTON
  // ==========================
  Widget _social(String title, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black26, width: 1.3),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.black87,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
