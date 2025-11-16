import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:orgtrack/app/data/models/KeuanganModel.dart';
import 'package:orgtrack/app/ui/keuangan/controllers/keuangan_controller.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';

class KeuanganView extends StatelessWidget {
  const KeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeuanganController>();
    final auth = Get.find<AuthController>();
    final filter = RxString('Semua');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),

      body: Column(
        children: [
          // ===================== HEADER GRADIENT =====================
          Container(
            padding:
                const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF009688),
                  Color(0xFF4DB6AC),
                  Color(0xFF80CBC4),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),

            child: Column(
              children: [
                // ===== ROW BACK + TITLE + FILTER =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol back
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

                    Text(
                      "Keuangan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    PopupMenuButton<String>(
                      icon:
                          const Icon(Icons.filter_alt_rounded, color: Colors.white),
                      color: Colors.white,
                      onSelected: (v) => filter.value = v,
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "Semua", child: Text("Semua")),
                        PopupMenuItem(value: "Pemasukan", child: Text("Pemasukan")),
                        PopupMenuItem(value: "Pengeluaran", child: Text("Pengeluaran")),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ===== SALDO SUMMARY =====
                Obx(() {
                  final saldo = c.totalSaldo();
                  final pemasukan = c.totalByType('Pemasukan');
                  final pengeluaran = c.totalByType('Pengeluaran');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _summaryCard("Saldo", saldo, Colors.teal),
                      _summaryCard("Masuk", pemasukan, Colors.green),
                      _summaryCard("Keluar", pengeluaran, Colors.red),
                    ],
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ===================== BODY =====================
          Expanded(
            child: Obx(() {
              final list = c.keuanganList
                  .where((k) => filter.value == 'Semua' || k.type == filter.value)
                  .toList();

              return RefreshIndicator(
                onRefresh: () async => c.refreshData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ===================== GRAFIK =====================
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              "Grafik Keuangan Bulanan",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text("Belum ada transaksi",
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 16)),
                            ),
                          )
                        : Column(
                            children: list.map((k) {
                              final date =
                                  DateFormat('dd MMM yyyy').format(k.date);
                              return _transactionTile(k, date, c, auth);
                            }).toList(),
                          ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),

      // ================= FAB ADMIN =================
      floatingActionButton: auth.userRole.value == "admin"
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal.shade600,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tambah", style: TextStyle(color: Colors.white)),
              onPressed: () => _showAddDialog(context, c),
            )
          : null,
    );
  }

  // ===================================================================
  // ====== SUMMARY CARD ===============================================
  // ===================================================================
  Widget _summaryCard(String title, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              "Rp ${value.toStringAsFixed(0)}",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // ====== TRANSACTION TILE ===========================================
  // ===================================================================
  Widget _transactionTile(Keuanganmodel k, String date,
      KeuanganController c, AuthController auth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: (k.type == "Pemasukan"
                  ? Colors.green
                  : Colors.red)
              .withOpacity(0.18),
          child: Icon(
            k.type == "Pemasukan"
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: k.type == "Pemasukan" ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          k.title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          "${k.type} • $date",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Text(
          "Rp ${k.amount.toStringAsFixed(0)}",
          style: TextStyle(
            color: k.type == "Pemasukan" ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showDetailDialog(k),
        onLongPress: auth.userRole.value == "admin"
            ? () => _showAddDialog(Get.context!, c, k)
            : null,
      ),
    );
  }

  // ===================================================================
  // ====== BAR CHART ===================================================
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
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const months = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                  ];
                  if (v < 0 || v > 11) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(months[v.toInt()],
                        style: const TextStyle(fontSize: 10)),
                  );
                }),
          ),
        ),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: pemasukan[i],
                color: Colors.green,
                width: 8,
              ),
              BarChartRodData(
                toY: pengeluaran[i],
                color: Colors.red,
                width: 8,
              ),
            ],
          );
        }),
      ),
    );
  }

  // ===================================================================
  // ====== ADD/EDIT dialog ============================================
  // ===================================================================
  void _showAddDialog(BuildContext context, KeuanganController c,
      [Keuanganmodel? old]) {
    final titleC = TextEditingController(text: old?.title ?? '');
    final amountC =
        TextEditingController(text: old?.amount.toString() ?? '');
    final type = RxString(old?.type ?? "Pemasukan");
    final date = Rx<DateTime?>(old?.date);

    Get.defaultDialog(
      title: old == null ? "Tambah Transaksi" : "Edit Transaksi",
      content: Column(
        children: [
          TextField(controller: titleC, decoration: const InputDecoration(labelText: "Judul")),
          TextField(controller: amountC, decoration: const InputDecoration(labelText: "Jumlah")),
          Obx(() => TextButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: date.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) date.value = d;
                },
                child: Text(
                  date.value == null
                      ? "Pilih Tanggal"
                      : DateFormat('dd MMM yyyy').format(date.value!),
                ),
              )),
          Obx(() => DropdownButton(
                value: type.value,
                items: ["Pemasukan", "Pengeluaran"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => type.value = v!,
              ))
        ],
      ),
      textConfirm: "Simpan",
      onConfirm: () {
        if (titleC.text.isEmpty ||
            amountC.text.isEmpty ||
            date.value == null) {
          Get.snackbar("Error", "Isi semua data!");
          return;
        }

        final data = Keuanganmodel(
          id: old?.id,
          title: titleC.text,
          amount: double.tryParse(amountC.text) ?? 0,
          type: type.value,
          date: date.value!,
        );

        if (old == null) {
          c.addKeuangan(data);
        } else {
          c.updateKeuangan(data);
        }

        Get.back();
      },
    );
  }

  // ===================================================================
  // ====== DETAIL DIALOG ==============================================
  // ===================================================================
  void _showDetailDialog(Keuanganmodel k) {
    Get.defaultDialog(
      title: "Detail Transaksi",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Judul: ${k.title}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Jumlah: Rp ${k.amount.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          Text("Tipe: ${k.type}"),
          const SizedBox(height: 8),
          Text("Tanggal: ${DateFormat('dd MMM yyyy').format(k.date)}"),
        ],
      ),
      textConfirm: "Tutup",
      onConfirm: () => Get.back(),
    );
  }
}
