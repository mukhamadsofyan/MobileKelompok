import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart'; // 🔥 Animasi elegan
import '../controllers/visi_misi_controller.dart';

class VisiMisiView extends GetView<VisiMisiController> {
  const VisiMisiView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final icons = [
      Icons.school_rounded,
      Icons.groups_rounded,
      Icons.lightbulb_rounded,
      Icons.public_rounded,
    ]; // ikon unik tiap misi

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visi & Misi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.teal.shade200,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDEF8F5),
              Color(0xFFE8FBF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== HEADER ILUSTRASI =====
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_rounded,
                        color: Colors.teal, size: 90),
                    const SizedBox(height: 10),
                    Text(
                      'Organisasi Mahasiswa Unggul',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),

              // ===== VISI CARD =====
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.remove_red_eye_rounded,
                              color: Colors.teal, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Visi',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        c.visi,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== MISI GRID =====
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: Row(
                  children: const [
                    Icon(Icons.flag_rounded, color: Colors.teal, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Misi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: c.misi.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio:
                      0.95, // 🔧 Turunkan sedikit agar muat teks panjang
                ),
                itemBuilder: (_, index) {
                  final misi = c.misi[index];
                  return FadeInUp(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    child: GestureDetector(
                      onTap: () {
                        Get.dialog(
                          ScaleTransitionDialog(
                            title: 'Misi ${index + 1}',
                            message: misi,
                            icon: icons[index % icons.length],
                          ),
                          transitionDuration: const Duration(milliseconds: 250),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.teal.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.teal.shade100, width: 1.3),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 16), // 🔧 Tambah ruang vertikal
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              // 🔧 Bungkus teks pakai Flexible supaya tidak overflow
                              child: Text(
                                misi,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== DIALOG KUSTOM DENGAN ANIMASI ======
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation =
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.1),
              radius: 32,
              child: Icon(widget.icon, color: Colors.teal, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.teal,
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
            color: Colors.grey.shade800,
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
