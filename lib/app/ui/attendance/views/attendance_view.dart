import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_controller.dart';
import '../../../controllers/auth_controller.dart';

class AttendanceView extends StatelessWidget {
  final AgendaOrganisasi agenda;
  const AttendanceView({Key? key, required this.agenda}) : super(key: key);

  static const Set<String> _unlockRoles = {"admin"};

  // ================= TAMBAHAN (NOTIF HANDLER) =================
  void _handleNotificationAction() {
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      final action = args['action'];

      if (action == 'checkin') {
        Get.snackbar(
          "Pengingat Absensi",
          "Silakan lakukan CHECK-IN",
          backgroundColor: Colors.teal,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      if (action == 'checkout') {
        Get.snackbar(
          "Pengingat Absensi",
          "Jangan lupa CHECK-OUT",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // 🔔 DIPANGGIL SETELAH BUILD SELESAI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationAction();
    });

    final AttendanceController controller =
        Get.put(AttendanceController(agenda: agenda));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ================= COLOR SYSTEM =================
    final bg = isDark ? const Color(0xFF0E1116) : const Color(0xFFF4F6FA);
    final textPrimary =
        isDark ? Colors.white.withOpacity(0.92) : const Color(0xFF121826);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;
    final textMuted = isDark ? Colors.white38 : Colors.black38;
    final teal1 = isDark ? Colors.teal.shade700 : Colors.teal.shade500;
    final teal2 = isDark ? Colors.teal.shade900 : Colors.teal.shade800;

    return Scaffold(
      backgroundColor: bg,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [teal1, teal2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Absensi Agenda",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            Text(
              agenda.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final locked = controller.isLocked.value;
            final isAdmin = _getCurrentRole() == "admin";

            return IconButton(
              tooltip: locked
                  ? (isAdmin
                      ? "Buka kunci absensi"
                      : "Hanya admin yang dapat membuka")
                  : "Absensi terbuka",
              icon: Icon(
                locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                color:
                    isAdmin ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              onPressed: (locked && isAdmin)
                  ? () => _unlockDialog(controller, isDark)
                  : null,
            );
          }),
        ],
      ),

      // ================= BODY =================
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.strukturalList.isEmpty) {
          return Center(
            child: Text(
              "Belum ada anggota struktural",
              style: TextStyle(color: textMuted),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: controller.strukturalList.length,
            itemBuilder: (_, i) {
              final s = controller.strukturalList[i];
              final hadir = controller.attendanceMap[s.id] ?? false;

              return _AnimatedItem(
                index: i,
                child: _GlassCard(
                  isDark: isDark,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        s.role,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusBadge(hadir: hadir),
                        const SizedBox(width: 12),
                        AnimatedCheckbox(
                          value: hadir,
                          enabled: !controller.isLocked.value,
                          onChanged: (_) =>
                              controller.toggleAttendance(s.id),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Obx(
        () => _BottomSaveBar(
          locked: controller.isLocked.value,
          onSave: controller.lockAttendance,
          isDark: isDark,
        ),
      ),
    );
  }

  void _unlockDialog(AttendanceController c, bool isDark) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Buka Kunci Absensi"),
        content: const Text(
          "Absensi akan dibuka dan dapat diubah kembali.",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              c.unlockAttendance();
              Get.back();
              Get.snackbar(
                "Berhasil",
                "Absensi berhasil dibuka",
                backgroundColor:
                    isDark ? const Color(0xFF0F2A23) : Colors.teal,
                colorText: Colors.white,
              );
            },
            child: const Text("Buka"),
          ),
        ],
      ),
    );
  }

  String _getCurrentRole() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>()
          .userRole
          .value
          .toLowerCase();
    }
    return "member";
  }
}

// ================= GLASS CARD =================
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _GlassCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ================= STATUS BADGE =================
class _StatusBadge extends StatelessWidget {
  final bool hadir;
  const _StatusBadge({required this.hadir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hadir
            ? Colors.teal.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hadir ? "HADIR" : "TIDAK HADIR",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: hadir ? Colors.teal : Colors.red,
        ),
      ),
    );
  }
}

// ================= ANIMATION =================
class _AnimatedItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index * 40)),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 10),
          child: child,
        ),
      ),
    );
  }
}

// ================= CHECKBOX =================
class AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const AnimatedCheckbox({
    Key? key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: value
              ? Colors.teal
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          value ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color:
              value ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
        ),
      ),
    );
  }
}

// ================= BOTTOM BAR =================
class _BottomSaveBar extends StatelessWidget {
  final bool locked;
  final VoidCallback onSave;
  final bool isDark;

  const _BottomSaveBar({
    required this.locked,
    required this.onSave,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 58,
        child: ElevatedButton.icon(
          icon: Icon(
            locked ? Icons.lock_rounded : Icons.save_rounded,
            size: 22,
          ),
          label: Text(
            locked ? "Absensi Terkunci" : "Simpan & Kunci Absensi",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          onPressed: locked ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: locked
                ? (isDark ? Colors.white12 : Colors.grey.shade400)
                : Colors.teal.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
