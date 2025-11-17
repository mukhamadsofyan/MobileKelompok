import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/theme_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/agenda_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final colorText = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: colorBG,

      body: Column(
        children: [
          // ===================== HEADER =====================
          Container(
            padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 15),
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
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
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
                        // TOGGLE TEMA
                        IconButton(
                          icon: Icon(
                            themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                            color: Colors.white,
                          ),
                          onPressed: () => themeC.toggleTheme(),
                        ),

                        PopupMenuButton<String>(
                          icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                          color: cardColor,
                          onSelected: (value) => filter.value = value,
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: "Semua", child: Text("Semua")),
                            const PopupMenuItem(value: "Mendatang", child: Text("Agenda Mendatang")),
                            const PopupMenuItem(value: "Selesai", child: Text("Agenda Selesai")),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // SEARCH
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
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: colorText.withOpacity(0.6)),
                      hintText: "Cari agenda...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: colorText.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================== LIST =============================
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              var list = controller.agendas.where((a) =>
                  a.title.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();

              if (filter.value == "Mendatang") {
                list = list.where((a) => a.date.isAfter(DateTime.now())).toList();
              } else if (filter.value == "Selesai") {
                list = list.where((a) => a.date.isBefore(DateTime.now())).toList();
              }

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 90, color: Colors.teal.shade200),
                      const SizedBox(height: 10),
                      Text("Tidak ada agenda",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
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
                  final date = DateFormat('dd MMM yyyy - HH:mm').format(a.date);

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 350 + (i * 70)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: _agendaCard(a, date, expired, cardColor, colorText),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // FAB hanya ADMIN
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal.shade700,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tambah", style: TextStyle(color: Colors.white)),
              onPressed: () => _showAgendaSheet(context),
            )
          : null,
    );
  }

  // ================= CARD AGENDA ===================
  Widget _agendaCard(AgendaOrganisasi a, String date, bool expired,
      Color cardColor, Color colorText) {
    final isAdmin = auth.isAdmin;

    return Card(
      elevation: 2,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: expired
              ? Colors.grey.shade400.withOpacity(0.3)
              : Colors.teal.shade100.withOpacity(0.7),
          child: Icon(
            expired ? Icons.event_busy : Icons.event_available,
            color: expired ? Colors.grey.shade700 : Colors.teal.shade700,
          ),
        ),

        title: Text(
          a.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: colorText,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.description != null && a.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  a.description!,
                  style: TextStyle(fontSize: 13, color: colorText.withOpacity(0.6)),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 15, color: Colors.teal.shade700),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: expired ? Colors.grey.shade700 : Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ],
        ),

        trailing: isAdmin
            ? PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _showAgendaSheet(context, agenda: a);
                  if (v == 'delete') _deleteConfirm(a);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.teal),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Hapus"),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // ===================== BOTTOM SHEET ADD/EDIT ====================
  void _showAgendaSheet(BuildContext context, {AgendaOrganisasi? agenda}) {
    if (!auth.isAdmin) {
      Get.snackbar("Akses Ditolak", "Hanya admin yang bisa menambah/edit agenda");
      return;
    }

    final titleC = TextEditingController(text: agenda?.title ?? '');
    final descC = TextEditingController(text: agenda?.description ?? '');
    final selected = Rxn<DateTime>(agenda?.date);

    Future pick() async {
      final now = DateTime.now();
      final d = await showDatePicker(
        context: context,
        initialDate: selected.value ?? now,
        firstDate: now,
        lastDate: DateTime(2100),
      );

      if (d != null) {
        final t = await showTimePicker(
          context: context,
          initialTime: selected.value != null
              ? TimeOfDay.fromDateTime(selected.value!)
              : TimeOfDay.now(),
        );

        if (t != null) {
          selected.value = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                agenda == null ? "Tambah Agenda" : "Edit Agenda",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal.shade800,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: titleC,
                decoration: _input("Judul Agenda"),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: descC,
                maxLines: 3,
                decoration: _input("Deskripsi"),
              ),

              const SizedBox(height: 14),

              Obx(
                () => TextButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Colors.teal),
                  label: Text(
                    selected.value == null
                        ? "Pilih Tanggal"
                        : DateFormat('dd MMM yyyy – HH:mm').format(selected.value!),
                    style: TextStyle(color: Colors.teal.shade600),
                  ),
                  onPressed: pick,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {
                    if (titleC.text.isEmpty || selected.value == null) {
                      Get.snackbar("Perhatian", "Semua data harus diisi",
                          backgroundColor: Colors.red.shade100);
                      return;
                    }

                    final item = AgendaOrganisasi(
                      id: agenda?.id,
                      title: titleC.text,
                      description: descC.text,
                      date: selected.value!,
                    );

                    if (agenda == null) {
                      controller.addAgenda(item);
                    } else {
                      controller.updateAgenda(item);
                    }

                    Get.back();
                  },

                  child: Text(agenda == null ? "Simpan" : "Perbarui"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
      ),
    );
  }

  // ===================== DELETE ==========================
  void _deleteConfirm(AgendaOrganisasi a) {
    if (!auth.isAdmin) {
      Get.snackbar("Akses Ditolak", "Hanya admin yang bisa menghapus agenda");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Hapus Agenda"),
        content: Text("Hapus '${a.title}'?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              controller.deleteAgenda(a.id!);
              Get.back();
              Get.snackbar("Berhasil", "Agenda dihapus",
                  backgroundColor: Colors.green.shade100);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
