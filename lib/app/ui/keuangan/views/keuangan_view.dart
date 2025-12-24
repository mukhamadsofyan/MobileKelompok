import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:orgtrack/app/controllers/theme_controller.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:orgtrack/app/ui/keuangan/controllers/keuangan_controller.dart';
import 'package:orgtrack/app/data/models/KeuanganModel.dart';

class KeuanganView extends StatelessWidget {
  const KeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeuanganController>();
    final auth = Get.find<AuthController>();
    final themeC = Get.find<ThemeController>();

    final filter = RxString('Semua');

    final colorBG = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final colorText = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: colorBG,

      body: Column(
        children: [
          // ===================== HEADER ==========================
          Container(
            padding: const EdgeInsets.only(
              top: 45,
              left: 20,
              right: 20,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(themeC.isDark ? 0.45 : 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK BUTTON
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
                      "Keuangan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // ACTIONS (TOGGLE + FILTER)
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
                          color: cardColor,
                          onSelected: (v) => filter.value = v,
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: "Semua", child: Text("Semua")),
                            PopupMenuItem(
                              value: "Pemasukan",
                              child: Text("Pemasukan"),
                            ),
                            PopupMenuItem(
                              value: "Pengeluaran",
                              child: Text("Pengeluaran"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ===================== SUMMARY ==========================
                Obx(() {
                  final saldo = c.totalSaldo();
                  final pemasukan = c.totalByType('Pemasukan');
                  final pengeluaran = c.totalByType('Pengeluaran');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _summaryCard(
                        "Saldo",
                        saldo,
                        Colors.teal,
                        cardColor,
                        colorText,
                      ),
                      _summaryCard(
                        "Masuk",
                        pemasukan,
                        Colors.green,
                        cardColor,
                        colorText,
                      ),
                      _summaryCard(
                        "Keluar",
                        pengeluaran,
                        Colors.red,
                        cardColor,
                        colorText,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ===================== BODY ==========================
          Expanded(
            child: Obx(() {
              final list = c.keuanganList
                  .where(
                    (k) => filter.value == 'Semua' || k.type == filter.value,
                  )
                  .toList();

              return RefreshIndicator(
                onRefresh: () async => c.refreshData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // GRAFIK
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              "Grafik Keuangan Bulanan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(height: 220, child: _barChart(c)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Daftar Transaksi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                "Belum ada transaksi",
                                style: TextStyle(
                                  color: colorText.withOpacity(0.6),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: list.map((k) {
                              final date = DateFormat(
                                'dd MMM yyyy',
                              ).format(k.date);
                              return _transactionTile(
                                k,
                                date,
                                c,
                                auth,
                                cardColor,
                                colorText,
                              );
                            }).toList(),
                          ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),

      floatingActionButton: auth.userRole.value == "admin"
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal.shade600,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Tambah",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _showAddDialog(context, c),
            )
          : null,
    );
  }

  // ===================================================================
  // SUMMARY CARD
  // ===================================================================
  Widget _summaryCard(
    String title,
    double value,
    Color color,
    Color cardColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Rp ${value.toStringAsFixed(0)}",
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // TRANSACTION TILE (UPDATED with TITIK TIGA)
  // ===================================================================
  Widget _transactionTile(
    Keuanganmodel k,
    String date,
    KeuanganController c,
    AuthController auth,
    Color cardColor,
    Color textColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          // MAIN TILE
          ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor:
                  (k.type == "Pemasukan" ? Colors.green : Colors.red)
                      .withOpacity(0.15),
              child: Icon(
                k.type == "Pemasukan"
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: k.type == "Pemasukan" ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              k.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            subtitle: Text(
              "${k.type} • $date",
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
            trailing: Text(
              "Rp ${k.amount.toStringAsFixed(0)}",
              style: TextStyle(
                color: k.type == "Pemasukan" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showDetailDialog(k),
          ),

          // TITIK TIGA ADMIN ONLY
          if (auth.userRole.value == "admin")
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: textColor.withOpacity(0.7)),
                onSelected: (v) {
                  if (v == 'edit') {
                    _showAddDialog(Get.context!, c, k);
                  } else if (v == 'delete') {
                    _confirmDeleteKeuangan(k, c);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text("Edit")),
                  PopupMenuItem(value: 'delete', child: Text("Hapus")),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===================================================================
  // DELETE CONFIRM
  // ===================================================================
  void _confirmDeleteKeuangan(Keuanganmodel k, KeuanganController c) {
    // ================= VALIDASI AKSES =================
    if (Get.find<AuthController>().userRole.value != "admin") {
      Get.snackbar(
        "Akses Ditolak",
        "Hanya admin yang bisa menghapus transaksi",
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
                "Hapus Transaksi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // ================= CONTENT =================
              Text(
                "Apakah kamu yakin ingin menghapus transaksi\n“${k.title}” ?",
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
                      onPressed: () async {
                        // TUTUP DIALOG DULU
                        Get.back();

                        await c.deleteKeuangan(k.id!);

                        // ================= NOTIFIKASI BERHASIL =================
                        Get.snackbar(
                          "Berhasil",
                          "Transaksi berhasil dihapus",
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
      barrierDismissible: false,
    );
  }

  // ===================================================================
  // BAR CHART
  // ===================================================================
  Widget _barChart(KeuanganController c) {
    final data = c.generateMonthlyDataByType();
    final pemasukan = data['Pemasukan']!;
    final pengeluaran = data['Pengeluaran']!;

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),

        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'Mei',
                  'Jun',
                  'Jul',
                  'Agu',
                  'Sep',
                  'Okt',
                  'Nov',
                  'Des',
                ];
                if (v < 0 || v > 11) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    months[v.toInt()],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),

        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(toY: pemasukan[i], color: Colors.green, width: 8),
              BarChartRodData(toY: pengeluaran[i], color: Colors.red, width: 8),
            ],
          );
        }),
      ),
    );
  }

  // ===================================================================
  // ADD / EDIT DIALOG
  // ===================================================================
  void _showAddDialog(
    BuildContext context,
    KeuanganController c, [
    Keuanganmodel? old,
  ]) {
    final titleC = TextEditingController(text: old?.title ?? '');
    final amountC = TextEditingController(text: old?.amount.toString() ?? '');
    final type = RxString(old?.type ?? "Pemasukan");
    final date = Rx<DateTime?>(old?.date);

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
                        child: Icon(
                          old == null
                              ? Icons.add_chart_rounded
                              : Icons.edit_rounded,
                          color: Colors.teal,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            old == null ? "Tambah Transaksi" : "Edit Transaksi",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Lengkapi data transaksi dengan benar",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= JUDUL =================
                  const Text(
                    "Judul",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleC,
                    decoration: InputDecoration(
                      hintText: "Contoh: Kas Bulanan",
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= JUMLAH =================
                  const Text(
                    "Jumlah",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Contoh: 50000",
                      prefixIcon: const Icon(Icons.payments_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= TANGGAL =================
                  const Text(
                    "Tanggal",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: date.value ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) date.value = d;
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded),
                            const SizedBox(width: 12),
                            Text(
                              date.value == null
                                  ? "Pilih Tanggal"
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(date.value!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= TIPE =================
                  const Text(
                    "Tipe",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: type.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.swap_vert_circle_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Pemasukan",
                          child: Text("Pemasukan"),
                        ),
                        DropdownMenuItem(
                          value: "Pengeluaran",
                          child: Text("Pengeluaran"),
                        ),
                      ],
                      onChanged: (v) => type.value = v!,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ================= BUTTON =================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // ===== VALIDASI (TIDAK DIUBAH) =====
                            if (titleC.text.trim().isEmpty ||
                                amountC.text.trim().isEmpty ||
                                date.value == null) {
                              Get.snackbar(
                                "Gagal",
                                "Semua field wajib diisi",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final data = Keuanganmodel(
                              id: old?.id,
                              title: titleC.text.trim(),
                              amount: double.tryParse(amountC.text) ?? 0,
                              type: type.value,
                              date: date.value!,
                            );

                            Get.back();

                            if (old == null) {
                              await c.addKeuangan(data);
                              Get.snackbar(
                                "Berhasil",
                                "Transaksi berhasil ditambahkan",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade600,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(12),
                              );
                            } else {
                              await c.updateKeuangan(data);
                              Get.snackbar(
                                "Berhasil",
                                "Transaksi berhasil diperbarui",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.blue.shade600,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(12),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            old == null ? "SIMPAN" : "UPDATE",
                            style: const TextStyle(
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

  // ===================================================================
  // DETAIL DIALOG
  // ===================================================================
  void _showDetailDialog(Keuanganmodel k) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= ICON =================
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 36,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================= TITLE =================
              const Center(
                child: Text(
                  "Detail Transaksi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 18),

              // ================= CONTENT =================
              _detailRow("Judul", k.title),
              _detailRow("Jumlah", "Rp ${k.amount.toStringAsFixed(0)}"),
              _detailRow("Tipe", k.type),
              _detailRow("Tanggal", DateFormat('dd MMM yyyy').format(k.date)),

              const SizedBox(height: 26),

              // ================= ACTION =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// helper kecil biar rapi
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
