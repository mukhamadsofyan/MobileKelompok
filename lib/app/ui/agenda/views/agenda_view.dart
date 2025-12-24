import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/theme_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/agenda_controller.dart';
import '../../../routes/app_pages.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final controller = Get.find<AgendaController>();
  final auth = Get.find<AuthController>();
  final themeC = Get.find<ThemeController>();

  final searchCtrl = TextEditingController();
  final filter = "Semua".obs;

  // footer model Home: 0 Beranda, 1 Agenda, 2 Notifikasi, 3 Profil
  int _currentIndex = 1;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ====== COLORS (biar gak nyaru) ======
    final bg = Theme.of(context).colorScheme.background;

    // Area list dibuat beda tone biar card kelihatan
    final listBg = isDark ? const Color(0xFF0F1413) : const Color(0xFFF2F6F5);

    // Card dibuat tegas: putih di light mode
    final agendaCardColor = isDark ? Theme.of(context).cardColor : Colors.white;

    // Border card biar kepisah jelas dari background
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    // Popup menu background biar tidak nyaru dengan card
    final popupBg = isDark ? const Color(0xFF1C1F1E) : Colors.white;
    final popupTextColor = isDark ? Colors.white : Colors.black87;

    // Search background di header
    final searchBg = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.95);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ===================== HEADER =====================
          Container(
            padding: const EdgeInsets.only(
              top: 45,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeC.isDark
                    ? const [
                        Color(0xFF00332E),
                        Color(0xFF004D40),
                        Color(0xFF003E39),
                      ]
                    : const [
                        Color(0xFF009688),
                        Color(0xFF4DB6AC),
                        Color(0xFF80CBC4),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                // ROW HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // back
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // TITLE
                    const Text(
                      "Agenda Organisasi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // TOGGLE + FILTER
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                            color: Colors.white,
                          ),
                          onPressed: () => themeC.toggleTheme(),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_alt_rounded,
                            color: Colors.white,
                          ),
                          color: popupBg,
                          onSelected: (value) => filter.value = value,
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: "Semua",
                              child: Text(
                                "Semua",
                                style: TextStyle(color: popupTextColor),
                              ),
                            ),
                            PopupMenuItem(
                              value: "Mendatang",
                              child: Text(
                                "Agenda Mendatang",
                                style: TextStyle(color: popupTextColor),
                              ),
                            ),
                            PopupMenuItem(
                              value: "Selesai",
                              child: Text(
                                "Agenda Selesai",
                                style: TextStyle(color: popupTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // SEARCH (biar kontras, tidak nyaru)
                Container(
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withOpacity(isDark ? 0.12 : 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      hintText: "Cari agenda...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================== LIST =============================
          Expanded(
            child: Container(
              color: listBg, // ✅ ini kunci biar card gak nyaru
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                var list = controller.agendas
                    .where(
                      (a) => a.title.toLowerCase().contains(
                        searchCtrl.text.toLowerCase(),
                      ),
                    )
                    .toList();

                if (filter.value == "Mendatang") {
                  list = list
                      .where((a) => a.date.isAfter(DateTime.now()))
                      .toList();
                } else if (filter.value == "Selesai") {
                  list = list
                      .where((a) => a.date.isBefore(DateTime.now()))
                      .toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 90,
                          color: isDark
                              ? Colors.tealAccent.withOpacity(0.45)
                              : Colors.teal.shade200,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada agenda",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final a = list[i];
                    final expired = a.date.isBefore(DateTime.now());
                    final date = DateFormat(
                      'dd MMM yyyy - HH:mm',
                    ).format(a.date);

                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 350 + (i * 70)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 26 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: _agendaCard(
                        a,
                        date,
                        expired,
                        agendaCardColor,
                        cardBorder,
                        isDark,
                        popupBg,
                        popupTextColor,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),

      // ✅ FOOTER
      bottomNavigationBar: _modernFooter(context),

      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal.shade700,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Tambah",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _showAgendaSheet(context),
            )
          : null,
    );
  }

  // ================= CARD AGENDA ===================
  Widget _agendaCard(
    AgendaOrganisasi a,
    String date,
    bool expired,
    Color cardColor,
    Color borderColor,
    bool isDark,
    Color popupBg,
    Color popupTextColor,
  ) {
    final isAdmin = auth.isAdmin;

    final accent = expired ? Colors.grey : Colors.teal;

    final iconBg = isDark
        ? (expired
              ? Colors.white.withOpacity(0.06)
              : Colors.teal.withOpacity(0.18))
        : (expired
              ? Colors.grey.shade300.withOpacity(0.55)
              : Colors.teal.shade100.withOpacity(0.75));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          leading: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: accent.withOpacity(isDark ? 0.35 : 0.22),
              ),
            ),
            child: Icon(
              expired ? Icons.event_busy : Icons.event_available,
              color: expired ? Colors.grey.shade700 : Colors.teal.shade700,
            ),
          ),
          title: Text(
            a.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.8,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((a.description ?? '').trim().isNotEmpty)
                  Text(
                    a.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.2,
                      height: 1.25,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if ((a.description ?? '').trim().isNotEmpty)
                  const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: expired
                              ? Colors.grey.shade600
                              : Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: expired ? Colors.red.shade50 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expired ? "Terlampaui" : "Tersedia",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: expired ? Colors.red : Colors.teal.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: isAdmin
              ? PopupMenuButton<String>(
                  color: popupBg,
                  onSelected: (v) {
                    if (v == 'edit') _showAgendaSheet(context, agenda: a);
                    if (v == 'delete') _deleteConfirm(a);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text("Edit", style: TextStyle(color: popupTextColor)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            "Hapus",
                            style: TextStyle(color: popupTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  // ===================== FOOTER ====================
  Widget _modernFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF009688),
                  Color(0xFF4DB6AC),
                  Color(0xFF80CBC4),
                ],
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.home, "Beranda", 0),
          _footerItem(Icons.event, "Agenda", 1),
          _footerItem(Icons.notifications, "Notifikasi", 2),
          _footerItem(Icons.person, "Profil", 3),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) return;

        setState(() => _currentIndex = index);

        switch (index) {
          case 0:
            Get.offAllNamed(Routes.HOME);
            break;
          case 1:
            Get.offAllNamed(Routes.AGENDA_ORGANISASI);
            break;
          case 2:
            Get.offAllNamed(Routes.NOTIFIKASI);
            break;
          case 3:
            Get.offAllNamed(Routes.PROFILE);
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== BOTTOM SHEET ADD/EDIT ====================
  // ✅ FIX: tombol SIMPAN sekarang reaktif (judul & tanggal mempengaruhi enable)
  void _showAgendaSheet(BuildContext context, {AgendaOrganisasi? agenda}) {
    // ================= AKSES =================
    if (!auth.isAdmin) {
      Get.snackbar(
        "Akses Ditolak",
        "Hanya admin yang bisa menambah atau mengedit agenda",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(Icons.block, color: Colors.white),
      );
      return;
    }

    final titleC = TextEditingController(text: agenda?.title ?? '');
    final descC = TextEditingController(text: agenda?.description ?? '');
    DateTime? selected = agenda?.date;

    // ================= PICK DATE & TIME =================
    Future<void> pick(StateSetter setModalState) async {
      final now = DateTime.now();
      final initialDate = selected != null && selected!.isAfter(now)
          ? selected!
          : now;

      final d = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(2100),
      );

      if (d != null) {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            selected != null && selected!.isAfter(now) ? selected! : now,
          ),
        );

        if (t != null) {
          final picked = DateTime(d.year, d.month, d.day, t.hour, t.minute);

          if (picked.isBefore(now)) {
            Get.snackbar(
              "Waktu Tidak Valid",
              "Agenda harus dijadwalkan ke waktu mendatang",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.shade600,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              borderRadius: 16,
              icon: const Icon(Icons.error, color: Colors.white),
            );
            return;
          }

          setModalState(() => selected = picked);
        }
      }
    }

    // ================= BOTTOM SHEET =================
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F9F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final isValid = titleC.text.trim().isNotEmpty && selected != null;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ================= TITLE =================
                  Row(
                    children: [
                      Icon(
                        agenda == null
                            ? Icons.event_available
                            : Icons.edit_calendar,
                        color: Colors.teal.shade700,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        agenda == null ? "Tambah Agenda" : "Edit Agenda",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Divider(color: Colors.teal.shade100),
                  const SizedBox(height: 18),

                  // ================= INPUT =================
                  TextFormField(
                    controller: titleC,
                    onChanged: (_) => setModalState(() {}),
                    decoration: _input(
                      ctx,
                      "Judul Agenda",
                      icon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descC,
                    maxLines: 3,
                    decoration: _input(
                      ctx,
                      "Deskripsi (opsional)",
                      icon: Icons.notes_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= PICK DATE =================
                  InkWell(
                    onTap: () => pick(setModalState),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected == null
                              ? Colors.grey.shade300
                              : Colors.teal.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.teal.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selected == null
                                  ? "Pilih tanggal & waktu"
                                  : DateFormat(
                                      'dd MMM yyyy • HH:mm',
                                    ).format(selected!),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected == null
                                    ? Colors.grey.shade600
                                    : Colors.teal.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ================= SAVE =================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () {
                              final item = AgendaOrganisasi(
                                id: agenda?.id,
                                title: titleC.text.trim(),
                                description: descC.text.trim(),
                                date: selected!,
                              );

                              agenda == null
                                  ? controller.addAgenda(item)
                                  : controller.updateAgenda(item);

                              Get.back();

                              // ================= NOTIFIKASI =================
                              Get.snackbar(
                                "Berhasil",
                                agenda == null
                                    ? "Agenda berhasil ditambahkan"
                                    : "Agenda berhasil diperbarui",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.teal.shade600,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 16,
                                icon: Icon(
                                  agenda == null
                                      ? Icons.event_available
                                      : Icons.edit_calendar,
                                  color: Colors.white,
                                ),
                                duration: const Duration(seconds: 2),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: isValid ? 4 : 0,
                        backgroundColor: isValid
                            ? Colors.teal.shade700
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "SIMPAN AGENDA",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isValid ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _input(BuildContext ctx, String label, {IconData? icon}) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.grey.shade700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
      ),
    );
  }

  void _deleteConfirm(AgendaOrganisasi a) {
    // ================= VALIDASI AKSES =================
    if (!auth.isAdmin) {
      Get.snackbar(
        "Akses Ditolak",
        "Hanya admin yang bisa menghapus agenda",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(Icons.block, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // ================= DIALOG KONFIRMASI =================
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= ICON =================
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  size: 36,
                  color: Colors.red.shade700,
                ),
              ),

              const SizedBox(height: 18),

              // ================= TITLE =================
              const Text(
                "Hapus Agenda",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // ================= CONTENT =================
              Text(
                "Apakah kamu yakin ingin menghapus agenda\n“${a.title}” ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 26),

              // ================= ACTION BUTTONS =================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteAgenda(a.id!);
                        Get.back();

                        // ================= NOTIFIKASI BERHASIL =================
                        Get.snackbar(
                          "Berhasil",
                          "Agenda berhasil dihapus",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green.shade600,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // ⛔ tidak bisa ditutup klik luar
    );
  }
}
