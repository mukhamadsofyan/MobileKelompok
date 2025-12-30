import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';

class AttendanceView extends StatefulWidget {
  final AgendaOrganisasi agenda;
  const AttendanceView({super.key, required this.agenda});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final ScrollController _scroll = ScrollController();
  double _offset = 0;

  late final AttendanceController c;
  late final AuthController authC;
  late final ThemeController themeC;

  String get _tag => 'attendance_${widget.agenda.id}';

  @override
  void initState() {
    super.initState();

    // controller per agenda
    c = Get.put(AttendanceController(agenda: widget.agenda), tag: _tag);

    authC = Get.find<AuthController>();
    themeC = Get.find<ThemeController>();

    _scroll.addListener(() {
      setState(() => _offset = _scroll.offset);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    Get.delete<AttendanceController>(tag: _tag);
    super.dispose();
  }

  bool get isAdmin => authC.isAdmin;
  bool get isExpired => widget.agenda.date.isBefore(DateTime.now());
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // =========================================================
  // 🔔 NOTIFIKASI DI ATAS (FIX – TEMBUS STACK & HEADER)
  // =========================================================
  void showTopNotif({
    required String title,
    required String message,
    required IconData icon,
    required Color bg,
  }) {
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: bg,
      borderRadius: 16,

      // 🔑 KUNCI POSISI PALING ATAS
      margin: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        0,
      ),

      duration: const Duration(seconds: 2),

      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BACK HANDLER =================
  Future<bool> _handleBack() async {
    if (!c.isLocked.value) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Perubahan belum disimpan"),
          content: const Text("Absensi belum disimpan. Simpan sebelum keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(Get.overlayContext!).pop(false);
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await c.saveAttendance();
                showTopNotif(
                  title: "Berhasil",
                  message: "Absensi berhasil disimpan",
                  icon: Icons.save,
                  bg: Colors.teal.shade600,
                );
                Navigator.of(Get.overlayContext!).pop(true);
              },
              child: const Text("Simpan & Keluar"),
            ),
          ],
        ),
      );

      if (confirm != true) return false;
    }
    return true;
  }

  Color _blend(Color a, Color b) {
    final t = (_offset / 200).clamp(0.0, 1.0);
    return Color.lerp(a, b, t)!;
  }

  double _headerHeight() => (220 - _offset / 2).clamp(120, 220).toDouble();

  BorderRadius _headerRadius() {
    final r = (40 - _offset / 6).clamp(0, 40).toDouble();
    return BorderRadius.vertical(bottom: Radius.circular(r));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: cs.background,

        // ================= BOTTOM BUTTON =================
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(() {
          if (!isAdmin || isExpired) return const SizedBox();

          return SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: FilledButton.icon(
              icon: Icon(c.isLocked.value ? Icons.edit : Icons.save),
              label: Text(
                c.isLocked.value ? "EDIT ABSENSI" : "SIMPAN ABSENSI",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                if (c.isLocked.value) {
                  c.confirmEditAttendance();
                  showTopNotif(
                    title: "Mode Edit",
                    message: "Absensi sekarang bisa diedit",
                    icon: Icons.edit,
                    bg: Colors.orange.shade600,
                  );
                } else {
                  await c.saveAttendance();
                  showTopNotif(
                    title: "Berhasil",
                    message: "Absensi berhasil disimpan",
                    icon: Icons.save,
                    bg: Colors.teal.shade600,
                  );
                }
              },
            ),
          );
        }),

        body: Stack(
          children: [
            // ================= HEADER =================
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: _headerHeight(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _blend(const Color(0xFF009688), const Color(0xFF004D40)),
                    _blend(const Color(0xFF4DB6AC), const Color(0xFF00796B)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: _headerRadius(),
              ),
            ),

            // ================= CONTENT =================
            SafeArea(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= TOP BAR =================
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final canBack = await _handleBack();
                            if (canBack) Get.back();
                          },
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Absensi",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                          ),
                          onPressed: themeC.toggleTheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _agendaCard(cs),
                    const SizedBox(height: 20),
                    _statusBanner(cs),
                    const SizedBox(height: 20),
                    Obx(() => _stats(cs)),

                    const SizedBox(height: 24),
                    const Text(
                      "Daftar Anggota",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (c.loading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Column(
                        children: c.strukturalList.map((s) {
                          final id = s.id!;
                          final hadir = c.attendanceMap[id] ?? false;

                          return _memberTile(
                            cs: cs,
                            id: id,
                            name: s.name,
                            role: s.role,
                            hadir: hadir,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AGENDA CARD =================
  Widget _agendaCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.agenda.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event, size: 18),
              const SizedBox(width: 6),
              Text(
                DateFormat(
                  'EEEE, dd MMM yyyy • HH:mm',
                ).format(widget.agenda.date),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS =================
  Widget _statusBanner(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isExpired
            ? cs.errorContainer
            : c.isLocked.value
            ? cs.tertiaryContainer
            : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isExpired
                ? Icons.event_busy
                : c.isLocked.value
                ? Icons.lock
                : Icons.edit,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isExpired
                  ? "Agenda telah terlampaui. Absensi hanya dapat dilihat."
                  : c.isLocked.value
                  ? "Absensi telah disimpan dan dikunci"
                  : "Absensi dapat diedit",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _stats(ColorScheme cs) {
    return Row(
      children: [
        _stat("Hadir", c.hadirCount.value, Colors.green),
        _stat("Tidak", c.tidakCount.value, Colors.red),
        _stat("Total", c.totalCount.value, Colors.teal),
      ],
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  // ================= MEMBER TILE =================
  Widget _memberTile({
    required ColorScheme cs,
    required int id,
    required String name,
    required String role,
    required bool hadir,
  }) {
    final canEdit = isAdmin && !isExpired && !c.isLocked.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(name[0]),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
        trailing: canEdit
            ? Switch(
                value: hadir,
                activeColor: cs.primary,
                onChanged: (val) {
                  c.toggleAttendance(id, val);
                  showTopNotif(
                    title: "Absensi Diperbarui",
                    message: val
                        ? "Anggota ditandai HADIR"
                        : "Anggota ditandai TIDAK HADIR",
                    icon: val ? Icons.check_circle : Icons.cancel,
                    bg: val ? Colors.green.shade600 : Colors.red.shade600,
                  );
                },
              )
            : Icon(
                hadir ? Icons.check_circle : Icons.cancel,
                color: hadir ? Colors.green : Colors.red,
              ),
      ),
    );
  }
}
