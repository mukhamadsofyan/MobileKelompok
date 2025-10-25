import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_controller.dart';

class AttendanceView extends StatelessWidget {
  final AgendaOrganisasi agenda;
  const AttendanceView({Key? key, required this.agenda}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController(agenda: agenda));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Absensi: ${agenda.title}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // 🔐 Tombol Admin Override
          Obx(() => IconButton(
                tooltip: controller.isLocked.value
                    ? "Buka kunci absensi (Admin)"
                    : "Absensi masih terbuka",
                icon: Icon(
                  controller.isLocked.value ? Icons.lock : Icons.lock_open,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (controller.isLocked.value) {
                    _showAdminUnlockDialog(controller);
                  } else {
                    Get.snackbar(
                      "Info",
                      "Absensi masih terbuka.",
                      backgroundColor: Colors.teal,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              )),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.teal));
        }

        if (controller.strukturalList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada anggota struktural',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.teal,
          onRefresh: () async => controller.refreshData(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            itemCount: controller.strukturalList.length,
            itemBuilder: (_, index) {
              final s = controller.strukturalList[index];
              final hadir = controller.attendanceMap[s.id] ?? false;
              return _AnimatedMemberCard(
                index: index,
                name: s.name,
                role: s.role,
                hadir: hadir,
                locked: controller.isLocked.value,
                onChanged: (v) {
                  if (!controller.isLocked.value && v != null) {
                    controller.toggleAttendance(s.id!);
                  }
                },
                onTap: () {
                  if (!controller.isLocked.value) {
                    _showMemberDetail(context, controller, s);
                  }
                },
              );
            },
          ),
        );
      }),
      bottomNavigationBar: Obx(() => _BottomSaveBar(
            locked: controller.isLocked.value,
            onSave: () {
              controller.lockAttendance(); // 🔐 Kunci absensi
              Get.snackbar(
                'Absensi Disimpan',
                'Data kehadiran berhasil dikunci!',
                backgroundColor: Colors.teal.shade600,
                colorText: Colors.white,
                icon: const Icon(Icons.lock, color: Colors.white),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          )),
    );
  }

  // 📌 Dialog untuk membuka kunci ulang oleh admin
  void _showAdminUnlockDialog(AttendanceController c) {
    final TextEditingController pinCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Buka Kunci Absensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan kode admin untuk membuka kunci absensi:"),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Masukkan PIN admin',
                prefixIcon: const Icon(Icons.lock_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinCtrl.text == "1234") {
                c.unlockAttendance();
                Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Kunci absensi telah dibuka oleh admin.',
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Gagal',
                  'PIN admin salah.',
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text("Buka Kunci"),
          ),
        ],
      ),
    );
  }

  // 📌 Bottom Sheet detail anggota (sama seperti versi kamu)
  void _showMemberDetail(
      BuildContext context, AttendanceController c, dynamic s) {
    final hadir = c.attendanceMap[s.id] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      s.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      s.role,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 16),
                  Text(
                    "Status Kehadiran",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatusButton(
                        icon: Icons.check_circle,
                        label: "Hadir",
                        color: Colors.green,
                        active: hadir == true,
                        onTap: () {
                          c.toggleAttendance(s.id!);
                          Get.back();
                        },
                      ),
                      _StatusButton(
                        icon: Icons.cancel_rounded,
                        label: "Alpa",
                        color: Colors.red,
                        active: hadir == false,
                        onTap: () {
                          c.attendanceMap[s.id] = false;
                          c.attendanceMap.refresh();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🧩 Animated Card
class _AnimatedMemberCard extends StatelessWidget {
  final int index;
  final String name;
  final String role;
  final bool hadir;
  final bool locked;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const _AnimatedMemberCard({
    required this.index,
    required this.name,
    required this.role,
    required this.hadir,
    required this.locked,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            leading: CircleAvatar(
              backgroundColor:
                  hadir ? Colors.green.shade100 : Colors.grey.shade300,
              radius: 28,
              child: Icon(
                hadir ? Icons.check_rounded : Icons.close_rounded,
                color: hadir ? Colors.green : Colors.grey,
                size: 26,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.5,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              role,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.5,
              ),
            ),
            trailing: Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: hadir,
                activeColor: Colors.teal,
                onChanged: locked ? null : onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🧩 Status Button (sama seperti sebelumnya)
class _StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 Bottom Save Bar
class _BottomSaveBar extends StatelessWidget {
  final bool locked;
  final VoidCallback onSave;
  const _BottomSaveBar({required this.locked, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: locked ? null : onSave,
              icon: Icon(
                locked ? Icons.lock : Icons.save_rounded,
                color: Colors.white,
              ),
              label: Text(
                locked ? "Absensi Terkunci" : "Simpan & Kunci",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    locked ? Colors.grey.shade500 : Colors.teal.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
