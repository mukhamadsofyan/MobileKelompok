import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import '../controllers/laporan_controller.dart';
import '../../../data/models/laporanModel.dart';

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
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorBG = cs.background;
    final colorText = cs.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
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
                // ================= ROW HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    // TITLE
                    const Text(
                      "Laporan Organisasi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // TOGGLE THEME
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => themeC.toggleTheme(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ================= SEARCH =================
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorText.withOpacity(0.6),
                      ),
                      hintText: "Cari judul atau deskripsi...",
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

          // ================= LIST =================
          Expanded(
            child: Obx(() {
              final keyword = searchC.text.trim().toLowerCase();

              final list = c.reports.where((r) {
                if (keyword.isEmpty) return true;
                return r.judul.toLowerCase().contains(keyword) ||
                    r.deskripsi.toLowerCase().contains(keyword);
              }).toList();

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          size: 90,
                          color: Colors.indigo.shade200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Belum ada laporan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorText.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          auth.isAdmin
                              ? "Tekan tombol Tambah untuk membuat laporan baru."
                              : "Laporan akan muncul ketika admin menambahkan data.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorText.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final report = list[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: auth.isAdmin
                          ? () => _showEditDialog(context, index, report)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ICON
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.judul,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: colorText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_rounded,
                                        size: 16,
                                        color: colorText.withOpacity(0.55),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        report.tanggal,
                                        style: TextStyle(
                                          color: colorText.withOpacity(0.65),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (report.deskripsi.trim().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      report.deskripsi,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colorText.withOpacity(0.75),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ACTION
                            if (auth.isAdmin) ...[
                              const SizedBox(width: 10),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _confirmDelete(context, index),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ================= FAB ADMIN ONLY =================
      floatingActionButton: auth.isAdmin
          ? Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: FloatingActionButton.extended(
                backgroundColor: themeC.isDark
                    ? const Color(0xFF00BFA5)
                    : const Color(0xFF009688),
                elevation: 2,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  "Tambah Laporan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: () => _showAddDialog(context),
              ),
            )
          : null,
    );
  }

  // =======================================================================================
  // FORM FIELD DECORATION (BIAR SERAGAM & RAPI)
  // =======================================================================================
  InputDecoration _decoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // =======================================================================================
  // POPUP TAMBAH
  // =======================================================================================
  void _showAddDialog(BuildContext context) {
    final judulCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    final tanggalCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split("T").first,
    );

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

    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.55,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= DRAG HANDLE =================
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // ================= HEADER =================
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.teal,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tambah Laporan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Lengkapi judul, tanggal, dan deskripsi",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= JUDUL =================
                  const Text(
                    "Judul Laporan",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: judulCtrl,
                    decoration: _decoration(
                      label: "Judul Laporan",
                      hint: "Contoh: Laporan Rapat Bulanan",
                      icon: Icons.title_rounded,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= TANGGAL =================
                  const Text(
                    "Tanggal",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tanggalCtrl,
                    readOnly: true,
                    decoration: _decoration(
                      label: "Tanggal",
                      hint: "Pilih tanggal laporan",
                      icon: Icons.event_rounded,
                      suffix: const Icon(Icons.calendar_today_rounded),
                    ),
                    onTap: pilihTanggal,
                  ),

                  const SizedBox(height: 22),

                  // ================= DESKRIPSI =================
                  const Text(
                    "Deskripsi",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: deskripsiCtrl,
                    maxLines: 5,
                    decoration: _decoration(
                      label: "Deskripsi",
                      hint: "Tulis ringkasan kegiatan / hasil laporan...",
                      icon: Icons.notes_rounded,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ================= BUTTON =================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            final judul = judulCtrl.text.trim();
                            final desc = deskripsiCtrl.text.trim();

                            if (judul.isEmpty) {
                              Get.snackbar(
                                "Gagal",
                                "Judul tidak boleh kosong",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            c.tambahLaporan(judul, tanggalCtrl.text, desc);

                            Get.back();

                            Get.snackbar(
                              "Berhasil",
                              "Laporan berhasil ditambahkan",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: const Text(
                            "SIMPAN DATA",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
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
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(BuildContext context, int index) {
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
                "Hapus Laporan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // ================= CONTENT =================
              Text(
                "Laporan yang dihapus tidak dapat dikembalikan.\n"
                "Apakah kamu yakin ingin menghapus laporan ini?",
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
                        // ================= TUTUP DIALOG DULU =================
                        Get.back();

                        // ================= HAPUS DATA =================
                        c.hapusLaporan(index);

                        // ================= NOTIFIKASI BERHASIL =================
                        Get.snackbar(
                          "Berhasil",
                          "Laporan berhasil dihapus",
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

  // =======================================================================================
  // POPUP EDIT
  // =======================================================================================
  void _showEditDialog(BuildContext context, int index, Report report) {
    final judulCtrl = TextEditingController(text: report.judul);
    final tanggalCtrl = TextEditingController(text: report.tanggal);
    final deskripsiCtrl = TextEditingController(text: report.deskripsi);

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

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit Laporan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),

                // ================= JUDUL =================
                TextField(
                  controller: judulCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: "Judul Laporan",
                    icon: Icons.title_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                // ================= TANGGAL =================
                TextField(
                  controller: tanggalCtrl,
                  readOnly: true,
                  decoration: _decoration(
                    label: "Tanggal",
                    icon: Icons.event_rounded,
                    suffix: const Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: () => pilihTanggal(),
                ),
                const SizedBox(height: 12),

                // ================= DESKRIPSI =================
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 5,
                  decoration: _decoration(
                    label: "Deskripsi",
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 16),

                // ================= BUTTON =================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final judul = judulCtrl.text.trim();
                          final desc = deskripsiCtrl.text.trim();

                          // ❌ VALIDASI
                          if (judul.isEmpty) {
                            Get.snackbar(
                              "Gagal",
                              "Judul tidak boleh kosong",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.9,
                              ),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 14,
                              icon: const Icon(
                                Icons.error_rounded,
                                color: Colors.white,
                              ),
                            );
                            return;
                          }

                          // ✅ UPDATE
                          c.editLaporan(index, judul, tanggalCtrl.text, desc);
                          Get.back();

                          // ✅ NOTIFIKASI BERHASIL
                          Get.snackbar(
                            "Berhasil",
                            "Laporan berhasil diperbarui",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blueAccent.withOpacity(0.9),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 14,
                            icon: const Icon(
                              Icons.update_rounded,
                              color: Colors.white,
                            ),
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
