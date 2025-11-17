import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../controllers/theme_controller.dart';
import '../controllers/visi_misi_controller.dart';

class VisiMisiView extends GetView<VisiMisiController> {
  const VisiMisiView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final themeC = Get.find<ThemeController>();

    final bgColor = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    final icons = [
      Icons.school_rounded,
      Icons.groups_rounded,
      Icons.lightbulb_rounded,
      Icons.public_rounded,
    ];

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Visi & Misi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeC.isDark
                  ? const [Color(0xFF00332E), Color(0xFF002A26)]
                  : const [Color(0xFF009688), Color(0xFF4DB6AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              themeC.isDark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            onPressed: () => themeC.toggleTheme(),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ================= HEADER ICON =================
            FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    color: themeC.isDark ? Colors.teal.shade200 : Colors.teal,
                    size: 90,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organisasi Mahasiswa Unggul',
                    style: TextStyle(
                      fontSize: 20,
                      color: themeC.isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),

            // ================= VISI CARD =================
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded,
                            color: Colors.teal.shade700, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          "Visi",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      c.visi,
                      style: TextStyle(
                        fontSize: 16.5,
                        color: textColor,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= MISI TITLE =================
            Row(
              children: [
                Icon(Icons.flag_rounded,
                    color: Colors.teal.shade700, size: 26),
                const SizedBox(width: 10),
                Text(
                  "Misi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= MISI GRID =================
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.misi.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.94,
              ),
              itemBuilder: (_, index) {
                final misi = c.misi[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  child: GestureDetector(
                    onTap: () => Get.dialog(
                      ScaleTransitionDialog(
                        title: "Misi ${index + 1}",
                        message: misi,
                        icon: icons[index % icons.length],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.teal.shade200,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.teal.withOpacity(0.12),
                            child: Icon(
                              icons[index % icons.length],
                              color: Colors.teal.shade700,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              misi,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
//                    KUSTOM DIALOG ANIMASI
// ===============================================================
class ScaleTransitionDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;

  const ScaleTransitionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  State<ScaleTransitionDialog> createState() => _ScaleTransitionDialogState();
}

class _ScaleTransitionDialogState extends State<ScaleTransitionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return ScaleTransition(
      scale: _scaleAnim,
      child: AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.12),
              radius: 32,
              child: Icon(widget.icon, color: Colors.teal, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          widget.message,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
