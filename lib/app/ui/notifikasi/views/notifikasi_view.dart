import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/theme_controller.dart';
import '../../agenda/controllers/agenda_controller.dart';
import '../../../routes/app_pages.dart';

class NotifikasiView extends StatelessWidget {
  NotifikasiView({super.key});

  final AgendaController c = Get.find<AgendaController>();
  final themeC = Get.find<ThemeController>();

  final searchCtrl = TextEditingController();
  final RxString filter = "Semua".obs; // Semua, Belum Dibaca, Sudah Dibaca, Hari Ini, Minggu Ini
  final RxInt currentIndex = 1.obs;

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final colorText = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: colorBG,

      body: Column(
        children: [
          // =====================================================
          // ===================== HEADER ========================
          // =====================================================
          Container(
            padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 20),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ),

                    const Text(
                      "Notifikasi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // TOGGLE MODE
                    IconButton(
                      icon: Icon(
                        themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                      ),
                      onPressed: themeC.toggleTheme,
                    )
                  ],
                ),

                const SizedBox(height: 16),

                // ===================== SEARCH BAR =====================
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
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
                    onChanged: (_) => c.notifications.refresh(),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: colorText.withOpacity(0.6)),
                      hintText: "Cari notifikasi...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: colorText.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ================== DROPDOWN FILTER ==================
                    Obx(
                      () => PopupMenuButton<String>(
                        color: cardColor,
                        onSelected: (v) => filter.value = v,
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt_rounded, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(filter.value,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: "Semua", child: Text("Semua")),
                          const PopupMenuItem(value: "Belum Dibaca", child: Text("Belum Dibaca")),
                          const PopupMenuItem(value: "Sudah Dibaca", child: Text("Sudah Dibaca")),
                          const PopupMenuItem(value: "Hari Ini", child: Text("Hari Ini")),
                          const PopupMenuItem(value: "Minggu Ini", child: Text("Minggu Ini")),
                        ],
                      ),
                    ),

                    // ============ TANDAI SEMUA TERBACA =============
                    TextButton.icon(
                      onPressed: () => _markAllRead(),
                      icon: const Icon(Icons.done_all, color: Colors.white),
                      label: const Text("Tandai Semua", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // =====================================================
          // ===================== LIST BODY =====================
          // =====================================================
          Expanded(
            child: Obx(() {
              if (c.loading.value) return const Center(child: CircularProgressIndicator());

              // ================= FILTER SEARCH ==================
              var list = c.notifications.where((a) {
                return a.title.toLowerCase().contains(searchCtrl.text.toLowerCase());
              }).toList();

              // ================== FILTER CATEGORY =================
              if (filter.value == "Belum Dibaca") {
                list = list.where((a) => a.isread == false).toList();
              } else if (filter.value == "Sudah Dibaca") {
                list = list.where((a) => a.isread == true).toList();
              } else if (filter.value == "Hari Ini") {
                list = list.where((a) => DateUtils.isSameDay(a.date, DateTime.now())).toList();
              } else if (filter.value == "Minggu Ini") {
                final now = DateTime.now();
                list = list.where((a) => now.difference(a.date).inDays < 7).toList();
              }

              if (list.isEmpty) return _emptyState();

              final grouped = _groupByDate(list);

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...entry.value.asMap().entries.map((map) {
                        final i = map.key;
                        final agenda = map.value;

                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 350 + (i * 80)),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 40 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: Dismissible(
                            key: ValueKey(agenda.id),
                            background: _deleteBg(),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => c.deleteNotification(agenda),

                            child: InkWell(
                              onTap: () {
                                c.markAsRead(agenda);
                                _showDetail(context, agenda);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _iconCircle(agenda),
                                    const SizedBox(width: 12),
                                    Expanded(child: _notificationText(agenda, colorText)),
                                    if (!agenda.isread)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  // ===========================================================
  // ===================== COMPONENTS ==========================
  // ===========================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text("Tidak ada notifikasi", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _iconCircle(agenda) {
    final expired = agenda.date.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expired ? Colors.grey.shade200 : Colors.teal.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        expired ? Icons.event_busy : Icons.event_available,
        color: expired ? Colors.grey.shade600 : Colors.teal.shade700,
        size: 26,
      ),
    );
  }

  Widget _notificationText(agenda, Color colorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          agenda.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colorText),
        ),
        const SizedBox(height: 4),
        Text(_timeAgo(agenda.date), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _deleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Colors.red.shade400,
      child: const Icon(Icons.delete, color: Colors.white, size: 26),
    );
  }

  // ===================== POPUP DETAIL ======================
  void _showDetail(BuildContext context, agenda) {
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(agenda.date);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(agenda.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                const SizedBox(width: 6),
                Text(formatted, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Text(agenda.description ?? "", style: const TextStyle(fontSize: 15)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Tutup")),
        ],
      ),
    );
  }

  // ===================== GROUPING ==========================
  Map<String, List> _groupByDate(List list) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final map = {
      "Hari Ini": [],
      "Kemarin": [],
      "Minggu Ini": [],
      "Sebelumnya": [],
    };

    for (var a in list) {
      final diff = today.difference(a.date).inDays;

      if (DateUtils.isSameDay(a.date, today)) {
        map["Hari Ini"]!.add(a);
      } else if (DateUtils.isSameDay(a.date, yesterday)) {
        map["Kemarin"]!.add(a);
      } else if (diff < 7) {
        map["Minggu Ini"]!.add(a);
      } else {
        map["Sebelumnya"]!.add(a);
      }
    }

    map.removeWhere((key, value) => value.isEmpty);
    return map;
  }

  // ===================== TIME AGO ==========================
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 7) return "${diff.inDays} hari lalu";

    return DateFormat("dd MMM yyyy").format(date);
  }

  // ============= TANDAI SEMUA TERBACA ======================
  void _markAllRead() {
    for (var n in c.notifications) {
      if (!n.isread) n.isread = true;
    }
    c.notifications.refresh();
  }

  // ===================== BOTTOM NAV ========================
  Widget _bottomNav() {
    return Obx(() {
      final unread = c.notifications.where((n) => n.isread == false).length;

      return BottomNavigationBar(
        currentIndex: currentIndex.value,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,

        onTap: (i) {
          currentIndex.value = i;

          if (i == 0) Get.offAllNamed(Routes.HOME);
          if (i == 1) {}
          if (i == 2) Get.toNamed(Routes.AGENDA_ORGANISASI);
          if (i == 3) Get.toNamed(Routes.STRUKTUR);
        },

        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Notifikasi",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Agenda"),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      );
    });
  }
}
