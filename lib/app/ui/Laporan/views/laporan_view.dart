import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import '../controllers/laporan_controller.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  final auth = Get.find<AuthController>();
  final themeC = Get.find<ThemeController>();
  final c = Get.find<LaporanController>();

  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,

      // ============================================================
      // HEADER PREMIUM SERAGAM
      // ============================================================
      body: Column(
        children: [
          // ===================== HEADER (SAMA DENGAN AGENDA) =====================
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
                // ================= ROW HEADER =================
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // TITLE
                    const Text(
                      "Laporan Organisasi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // TOGGLE THEME
                    IconButton(
                      icon: Icon(
                        themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                      ),
                      onPressed: () => themeC.toggleTheme(),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ================= SEARCH =================
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorText.withOpacity(0.6),
                      ),
                      hintText: "Cari laporan...",
                      hintStyle: TextStyle(color: colorText.withOpacity(0.5)),
                      border: InputBorder.none,
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


          const SizedBox(height: 10),

          // ============================================================
          // LIST REPORT
          // ============================================================
          Expanded(
            child: Obx(() {
              var list = c.reports
                  .where((r) => r.judul
                      .toLowerCase()
                      .contains(searchC.text.toLowerCase()))
                  .toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insert_drive_file_rounded,
                          size: 90, color: Colors.indigo.shade200),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada laporan",
                        style: TextStyle(
                            fontSize: 16, color: colorText.withOpacity(0.7)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final report = list[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.indigo.shade100,
                        child: const Icon(Icons.description_rounded,
                            color: Colors.indigo),
                      ),
                      title: Text(
                        report.judul,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorText,
                        ),
                      ),
                      subtitle: Text(
                        report.tanggal,
                        style: TextStyle(
                          color: colorText.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),

                      // EDIT — ONLY ADMIN
                      onTap: auth.isAdmin
                          ? () => _showEditDialog(context, index, report)
                          : null,

                      trailing: auth.isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => c.hapusLaporan(index),
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ============================================================
      // FAB ADMIN ONLY
      // ============================================================
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.indigo,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tambah", style: TextStyle(color: Colors.white)),
              onPressed: () => _showAddDialog(context),
            )
          : null,
    );
  }

  // =======================================================================================
  // POPUP TAMBAH
  // =======================================================================================
  void _showAddDialog(BuildContext context) {
    final judulCtrl = TextEditingController();
    final tanggalCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().split("T").first);

    Future<void> pilihTanggal() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        tanggalCtrl.text = picked.toIso8601String().split("T").first;
      }
    }

    Get.defaultDialog(
      title: "Tambah Laporan",
      content: Column(
        children: [
          TextField(
            controller: judulCtrl,
            decoration: const InputDecoration(labelText: "Judul"),
          ),
          TextField(
            controller: tanggalCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Tanggal",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => pilihTanggal(),
          ),
        ],
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      onConfirm: () {
        if (judulCtrl.text.isNotEmpty) {
          c.tambahLaporan(judulCtrl.text, tanggalCtrl.text);
          Get.back();
        }
      },
    );
  }

  // =======================================================================================
  // POPUP EDIT
  // =======================================================================================
  void _showEditDialog(BuildContext context, int index, report) {
    final judulCtrl = TextEditingController(text: report.judul);
    final tanggalCtrl = TextEditingController(text: report.tanggal);

    Future<void> pilihTanggal() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse(report.tanggal) ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        tanggalCtrl.text = picked.toIso8601String().split("T").first;
      }
    }

    Get.defaultDialog(
      title: "Edit Laporan",
      content: Column(
        children: [
          TextField(
            controller: judulCtrl,
            decoration: const InputDecoration(labelText: "Judul"),
          ),
          TextField(
            controller: tanggalCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Tanggal",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => pilihTanggal(),
          ),
        ],
      ),
      textConfirm: "Update",
      textCancel: "Batal",
      onConfirm: () {
        if (judulCtrl.text.isNotEmpty) {
          c.editLaporan(index, judulCtrl.text, tanggalCtrl.text);
          Get.back();
        }
      },
    );
  }
}
