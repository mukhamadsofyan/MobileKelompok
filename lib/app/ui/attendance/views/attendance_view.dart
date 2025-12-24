import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_controller.dart';
import '../../../controllers/auth_controller.dart';

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

  @override
  void initState() {
    super.initState();
    c = Get.find<AttendanceController>();
    authC = Get.find<AuthController>();

    _scroll.addListener(() {
      setState(() => _offset = _scroll.offset);
    });
  }

  bool get isAdmin => authC.isAdmin;
  bool get isExpired => widget.agenda.date.isBefore(DateTime.now());

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

    return Scaffold(
      backgroundColor: cs.background,

      // ================= FAB (ADMIN & TIDAK EXPIRED) =================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        // ❗ expired = READ ONLY (admin pun tidak boleh edit)
        if (!isAdmin || c.isLocked.value || isExpired) {
          return const SizedBox();
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: FilledButton.icon(
            onPressed: c.lockAttendance,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.lock_rounded),
            label: const Text(
              "SIMPAN & KUNCI ABSENSI",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  // BACK + TITLE
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: Get.back,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Absensi",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _agendaCard(cs),

                  const SizedBox(height: 20),
                  _statusBanner(cs),

                  const SizedBox(height: 20),
                  _stats(cs),

                  const SizedBox(height: 24),
                  const Text(
                    "Daftar Anggota",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ================= LIST =================
                  Obx(() {
                    if (c.loading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Column(
                      children: c.strukturalList.map((s) {
                        final id = s.id;
                        final hadir = id != null
                            ? c.attendanceMap[id] ?? false
                            : false;

                        return _memberTile(
                          cs: cs,
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
                DateFormat('EEEE, dd MMM yyyy • HH:mm')
                    .format(widget.agenda.date),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS BANNER =================
  Widget _statusBanner(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isExpired ? cs.errorContainer : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.event_busy : Icons.visibility,
            color: isExpired
                ? cs.onErrorContainer
                : cs.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isExpired
                  ? "Agenda telah terlampaui. Absensi hanya dapat dilihat."
                  : isAdmin
                      ? "Admin dapat mengubah status kehadiran"
                      : "Anda hanya dapat melihat absensi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpired
                    ? cs.onErrorContainer
                    : cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _stats(ColorScheme cs) {
    final total = c.strukturalList.length;
    final hadir = c.attendanceMap.values.where((e) => e == true).length;

    return Row(
      children: [
        _stat("Hadir", hadir, Colors.green),
        _stat("Tidak", total - hadir, Colors.red),
        _stat("Total", total, Colors.teal),
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

  // ================= MEMBER TILE (READ ONLY) =================
  Widget _memberTile({
    required ColorScheme cs,
    required String name,
    required String role,
    required bool hadir,
  }) {
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
          child: Text(name.isNotEmpty ? name[0] : "?"),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
        trailing: Icon(
          hadir ? Icons.check_circle : Icons.cancel,
          color: hadir ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
