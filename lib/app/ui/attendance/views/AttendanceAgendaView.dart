import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/theme_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_agenda.dart';

class AttendanceAgendaView extends StatefulWidget {
  const AttendanceAgendaView({super.key});

  @override
  State<AttendanceAgendaView> createState() => _AttendanceAgendaViewState();
}

class _AttendanceAgendaViewState extends State<AttendanceAgendaView> {
  final agendaC = Get.find<AttendanceAgendaController>();
  final themeC = Get.find<ThemeController>();

  final searchCtrl = TextEditingController();
  final filter = "Semua".obs;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = themeC.isDark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ===================== HEADER (samakan gaya AgendaView) =====================
          _GradientHeader(
            title: "Agenda Kehadiran",
            subtitle: "Kelola dan pantau absensi agenda",
            isDark: isDark,
            onBack: () => Get.back(),
            onToggleTheme: themeC.toggleTheme,
          ),

          // ===================== SEARCH =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _SearchField(
              controller: searchCtrl,
              hint: "Cari agenda absensi...",
              onChanged: (_) => setState(() {}),
            ),
          ),

          // ===================== FILTER =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(
              () => _SegmentFilter(
                value: filter.value,
                onChanged: (v) => filter.value = v,
              ),
            ),
          ),

          // ===================== LIST =====================
          Expanded(
            child: Stack(
              children: [
                // Background grid profesional (lebih halus + premium)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PremiumDotGridPainter(
                        // auto adapt
                        dotColor: cs.onSurface.withOpacity(isDark ? .10 : .06),
                        glowColor:
                            (isDark ? cs.primary : cs.primary).withOpacity(.08),
                      ),
                    ),
                  ),
                ),

                // Soft vignette biar keliatan “depth”
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.55),
                          radius: 1.25,
                          colors: [
                            Colors.transparent,
                            cs.surface.withOpacity(isDark ? .18 : .10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Obx(() {
                  if (agendaC.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final now = DateTime.now();
                  var list = agendaC.agendaList.where((a) {
                    final q = searchCtrl.text.trim().toLowerCase();
                    if (q.isEmpty) return true;
                    return a.title.toLowerCase().contains(q) ||
                        (a.description ?? "").toLowerCase().contains(q);
                  }).toList();

                  if (filter.value == "Tersedia") {
                    list = list.where((a) => a.date.isAfter(now)).toList();
                  } else if (filter.value == "Terlampaui") {
                    list = list.where((a) => a.date.isBefore(now)).toList();
                  }

                  list.sort((a, b) => a.date.compareTo(b.date));

                  if (list.isEmpty) {
                    return _EmptyState(
                      title: "Tidak ada agenda",
                      subtitle: "Coba ubah filter atau kata kunci pencarian.",
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final a = list[i];
                      final expired = a.date.isBefore(DateTime.now());

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 320 + (i * 55)),
                        tween: Tween(begin: 0, end: 1),
                        builder: (_, v, child) => Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - v)),
                            child: child,
                          ),
                        ),
                        child: _AttendanceAgendaCard(
                          agenda: a,
                          expired: expired,
                          onTap: () {
                            // ✅ tetap bisa dipencet
                            Get.toNamed(Routes.ATTENDANCE, arguments: a);
                          },
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== HEADER (gradient ala AgendaView) =====================
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onToggleTheme;

  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onBack,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final colors = isDark
        ? const [
            Color(0xFF00332E),
            Color(0xFF004D40),
            Color(0xFF003E39),
          ]
        : const [
            Color(0xFF009688),
            Color(0xFF4DB6AC),
            Color(0xFF80CBC4),
          ];

    return Container(
      padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(isDark ? .35 : .18),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(.22),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white.withOpacity(.88),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onToggleTheme,
                icon: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Small “status strip” biar berasa profesional
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(.18),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.how_to_reg_rounded,
                    color: Colors.white.withOpacity(.95), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Pilih agenda untuk melihat & mengelola kehadiran",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    "Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: .2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== SEARCH FIELD =====================
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged("");
                  },
                  icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ===================== FILTER SEGMENT =====================
class _SegmentFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item({
      required String label,
      required String v,
      required IconData icon,
      required Color activeColor,
    }) {
      final active = value == v;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? activeColor.withOpacity(.18)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active
                    ? activeColor.withOpacity(.35)
                    : cs.outlineVariant.withOpacity(.30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: active ? activeColor : cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: active ? activeColor : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: Row(
        children: [
          item(
            label: "Semua",
            v: "Semua",
            icon: Icons.apps_rounded,
            activeColor: cs.primary,
          ),
          const SizedBox(width: 6),
          item(
            label: "Tersedia",
            v: "Tersedia",
            icon: Icons.event_available_rounded,
            activeColor: cs.tertiary,
          ),
          const SizedBox(width: 6),
          item(
            label: "Terlampaui",
            v: "Terlampaui",
            icon: Icons.event_busy_rounded,
            activeColor: cs.error,
          ),
        ],
      ),
    );
  }
}

// ===================== AGENDA CARD (lebih pro) =====================
class _AttendanceAgendaCard extends StatelessWidget {
  final AgendaOrganisasi agenda;
  final bool expired;
  final VoidCallback onTap;

  const _AttendanceAgendaCard({
    required this.agenda,
    required this.expired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final accent = expired ? cs.error : cs.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withOpacity(.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.07),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Accent bar kiri biar “enterprise”
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  color: accent.withOpacity(.85),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon bubble
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        expired
                            ? Icons.event_busy_rounded
                            : Icons.event_available_rounded,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agenda.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 16, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('dd MMM yyyy • HH:mm')
                                    .format(agenda.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                          if ((agenda.description ?? "").trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              agenda.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Chip status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: accent.withOpacity(.22)),
                      ),
                      child: Text(
                        expired ? "Terlampaui" : "Tersedia",
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: .2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== EMPTY STATE =====================
class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: cs.primary.withOpacity(.15)),
              ),
              child: Icon(Icons.event_note_rounded,
                  size: 44, color: cs.primary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== PREMIUM GRID PAINTER =====================
class _PremiumDotGridPainter extends CustomPainter {
  final Color dotColor;
  final Color glowColor;

  _PremiumDotGridPainter({required this.dotColor, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1) base dots
    const gap = 26.0; // lebih lega (lebih premium)
    final dotPaint = Paint()..color = dotColor;

    for (double y = 0; y < size.height; y += gap) {
      for (double x = 0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.15, dotPaint);
      }
    }

    // 2) subtle glow spots (buat depth)
    final glow = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.18),
      120,
      glow,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.40),
      160,
      glow,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.78),
      190,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumDotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor || oldDelegate.glowColor != glowColor;
  }
}
