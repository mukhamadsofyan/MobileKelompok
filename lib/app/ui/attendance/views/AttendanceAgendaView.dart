import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import 'package:orgtrack/app/ui/attendance/controllers/attendance_agenda.dart';
import 'package:orgtrack/services/notification_service.dart';
import '../../../data/models/AgendaModel.dart';
import '../../../routes/app_pages.dart';

class AttendanceAgendaView extends StatefulWidget {
  @override
  State<AttendanceAgendaView> createState() => _AttendanceAgendaViewState();
}

class _AttendanceAgendaViewState extends State<AttendanceAgendaView> {
  final AttendanceAgendaController agendaC =
      Get.find<AttendanceAgendaController>();
  final themeC = Get.find<ThemeController>();

  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final colorCard = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.only(
                top: 45, left: 20, right: 20, bottom: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeC.isDark
                    ? const [Color(0xFF00332E), Color(0xFF002A26)]
                    : const [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                        Color(0xFF80CBC4)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      themeC.isDark ? 0.4 : 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    const Text(
                      "Agenda Kehadiran",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        themeC.isDark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Colors.white,
                      ),
                      onPressed: () => themeC.toggleTheme(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: colorCard,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: colorText.withOpacity(0.6)),
                      hintText: "Cari agenda...",
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================= LIST =================
          Expanded(
            child: Obx(() {
              if (agendaC.loading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              final list = agendaC.agendaList
                  .where((a) => a.title
                      .toLowerCase()
                      .contains(searchCtrl.text.toLowerCase()))
                  .toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 90, color: Colors.teal.shade200),
                      const SizedBox(height: 10),
                      Text("Tidak ada agenda ditemukan",
                          style: TextStyle(
                              fontSize: 16, color: colorText)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(20, 10, 20, 120),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final agenda = list[i];
                  return _AnimatedAgendaCard(
                    index: i,
                    agenda: agenda,
                    colorText: colorText,
                    cardColor: colorCard,
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ================= FAB (TEST NOTIFIKASI) =================
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "testNotif",
            backgroundColor: Colors.orange,
            child: const Icon(Icons.notifications_active),
            onPressed: () {
              final notif = Get.find<NotificationService>();

              notif.showLocalTestNotification(
                title: "Pengingat Absensi",
                body: "Saatnya CHECK-IN agenda hari ini",
                payload: {
                  "type": "attendance",
                  "action": "checkin",
                },
              );

              Get.snackbar(
                "Test Notifikasi",
                "Notifikasi absensi dikirim",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "reload",
            onPressed: () => agendaC.loadAgenda(),
            backgroundColor: Colors.teal.shade700,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Muat Ulang",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      bottomNavigationBar: const _FooterHint(),
    );
  }
}

// =============================================================
// CARD AGENDA (ASLI - TIDAK DIUBAH)
// =============================================================
class _AnimatedAgendaCard extends StatefulWidget {
  final int index;
  final AgendaOrganisasi agenda;
  final Color colorText;
  final Color cardColor;

  const _AnimatedAgendaCard({
    required this.index,
    required this.agenda,
    required this.colorText,
    required this.cardColor,
  });

  @override
  State<_AnimatedAgendaCard> createState() => _AnimatedAgendaCardState();
}

class _AnimatedAgendaCardState extends State<_AnimatedAgendaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _scale = CurvedAnimation(
        parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() => _controller.dispose();

  @override
  Widget build(BuildContext context) {
    final agenda = widget.agenda;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: () {
            if (agenda.id == null) {
              Get.snackbar(
                "Agenda Tidak Valid",
                "Agenda ini belum memiliki ID",
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
              );
              return;
            }

            Get.toNamed(Routes.ATTENDANCE, arguments: agenda);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor:
                    Colors.teal.shade100.withOpacity(0.7),
                child: Text(
                  agenda.title.isNotEmpty
                      ? agenda.title[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
              ),
              title: Text(
                agenda.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.colorText,
                ),
              ),
              subtitle: Text(
                agenda.description ?? "Tidak ada deskripsi",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: widget.colorText.withOpacity(0.6)),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.teal.shade300, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// FOOTER (ASLI)
// =============================================================
class _FooterHint extends StatelessWidget {
  const _FooterHint();

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeC.isDark
                    ? [Colors.black54, Colors.black45]
                    : [
                        Colors.white.withOpacity(0.85),
                        Colors.white.withOpacity(0.95)
                      ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    color: Colors.teal.shade700),
                const SizedBox(width: 10),
                Text(
                  'Pilih agenda untuk mulai absensi',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
