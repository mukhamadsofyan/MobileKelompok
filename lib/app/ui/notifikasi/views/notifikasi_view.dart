import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/theme_controller.dart';
import '../../agenda/controllers/agenda_controller.dart';
import '../../../routes/app_pages.dart';

class NotifikasiView extends StatefulWidget {
  const NotifikasiView({super.key});

  @override
  State<NotifikasiView> createState() => _NotifikasiViewState();
}

class _NotifikasiViewState extends State<NotifikasiView> {
  final AgendaController c = Get.find<AgendaController>();
  final ThemeController themeC = Get.find<ThemeController>();

  final TextEditingController searchCtrl = TextEditingController();
  final RxString filter = "Semua".obs;

  int _currentIndex = 2; // 🔥 NOTIFIKASI AKTIF

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.background;
    final text = Theme.of(context).colorScheme.onBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _header(context),
          _body(text),
        ],
      ),
      bottomNavigationBar: _modernFooter(context, isDark),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeC.isDark
              ? const [Color(0xFF00332E), Color(0xFF004D40)]
              : const [Color(0xFF009688), Color(0xFF4DB6AC)],
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
              _circleBtn(Icons.arrow_back_ios_new_rounded, Get.back),
              const Text(
                "Notifikasi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                ),
                onPressed: themeC.toggleTheme,
              )
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => c.notifications.refresh(),
              decoration: const InputDecoration(
                hintText: "Cari notifikasi...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => PopupMenuButton<String>(
                  onSelected: (v) => filter.value = v,
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt_rounded,
                          color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        filter.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "Semua", child: Text("Semua")),
                    PopupMenuItem(
                        value: "Belum Dibaca",
                        child: Text("Belum Dibaca")),
                    PopupMenuItem(
                        value: "Sudah Dibaca",
                        child: Text("Sudah Dibaca")),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all, color: Colors.white),
                label: const Text(
                  "Tandai Semua",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================
  Widget _body(Color textColor) {
    return Expanded(
      child: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        var list = c.notifications.where((a) {
          return a.title
              .toLowerCase()
              .contains(searchCtrl.text.toLowerCase());
        }).toList();

        if (filter.value == "Belum Dibaca") {
          list = list.where((a) => !a.isread).toList();
        } else if (filter.value == "Sudah Dibaca") {
          list = list.where((a) => a.isread).toList();
        }

        if (list.isEmpty) return _emptyState();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final n = list[i];

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                c.markAsRead(n);
                _detail(n);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    _iconCircle(n),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _timeAgo(n.date),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (!n.isread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // =========================================================
  // FOOTER — 100% SAMA HOME
  // =========================================================
  Widget _modernFooter(BuildContext context, bool isDark) {
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
        setState(() => _currentIndex = index);

        if (index == 0) Get.offAllNamed(Routes.HOME);
        if (index == 1) Get.offAllNamed(Routes.AGENDA_ORGANISASI);
        if (index == 2) {}
        if (index == 3) Get.offAllNamed(Routes.PROFILE);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: active ? Colors.white : Colors.white70,
          ),
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

  // =========================================================
  // UTIL
  // =========================================================
  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _iconCircle(n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: n.isread ? Colors.grey.shade200 : Colors.teal.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications,
        color: n.isread ? Colors.grey : Colors.teal,
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off,
              size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text("Tidak ada notifikasi"),
        ],
      ),
    );
  }

  void _detail(n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(n.title),
        content: Text(n.description ?? "-"),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Tutup")),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 7) return "${diff.inDays} hari lalu";
    return DateFormat("dd MMM yyyy").format(date);
  }

  void _markAllRead() {
    for (var n in c.notifications) {
      n.isread = true;
    }
    c.notifications.refresh();
  }
}
