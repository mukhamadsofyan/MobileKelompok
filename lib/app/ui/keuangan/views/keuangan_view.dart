import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:orgtrack/app/data/models/KeuanganModel.dart';
import 'package:orgtrack/app/ui/keuangan/controllers/keuangan_controller.dart';

class KeuanganView extends StatelessWidget {
  const KeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeuanganController>();
    final filter = RxString('Semua');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Dashboard Keuangan'),
        actions: [
          Obx(() => DropdownButton<String>(
                value: filter.value,
                underline: const SizedBox(),
                dropdownColor: Colors.orange[100],
                items: ['Semua', 'Pemasukan', 'Pengeluaran']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => filter.value = v!,
              ))
        ],
      ),
      body: Obx(() {
        final saldo = c.totalSaldo();
        final pemasukan = c.totalByType('Pemasukan');
        final pengeluaran = c.totalByType('Pengeluaran');
        final list = c.keuanganList
            .where((k) => filter.value == 'Semua' || k.type == filter.value)
            .toList();

        return RefreshIndicator(
          onRefresh: () async => c.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Ringkasan saldo ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryCard('Saldo', saldo, Colors.orange),
                  _summaryCard('Pemasukan', pemasukan, Colors.green),
                  _summaryCard('Pengeluaran', pengeluaran, Colors.red),
                ],
              ),
              const SizedBox(height: 20),

              // --- Grafik per bulan ---
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grafik Pemasukan & Pengeluaran per Bulan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(height: 220, child: _barChart(c)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendDot(Colors.green, 'Pemasukan'),
                          const SizedBox(width: 16),
                          _legendDot(Colors.red, 'Pengeluaran'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Daftar transaksi ---
              Text('Daftar Transaksi',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Belum ada transaksi')),
                    )
                  : Column(
                      children: list.map((k) {
                        final formattedDate =
                            DateFormat('dd MMM yyyy').format(k.date);

                        return Dismissible(
                          key: Key(k.id.toString()),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            // Konfirmasi sebelum hapus
                            return await Get.dialog<bool>(
                                  AlertDialog(
                                    title: const Text('Hapus Transaksi'),
                                    content: Text(
                                        'Apakah kamu yakin ingin menghapus "${k.title}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (direction) async {
                            await c.deleteKeuangan(k.id!);
                            Get.snackbar('Berhasil', 'Transaksi dihapus');
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: k.type == 'Pemasukan'
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                child: Icon(
                                  k.type == 'Pemasukan'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: k.type == 'Pemasukan'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                k.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${k.type} • $formattedDate'),
                              trailing: Text(
                                'Rp ${k.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: k.type == 'Pemasukan'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => _showDetailDialog(context, k),
                              onLongPress: () => _showAddDialog(context, c, k),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showAddDialog(context, c),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Ringkasan saldo ---
  Widget _summaryCard(String title, double value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Rp ${value.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: color.withOpacity(0.9))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // --- Grafik batang per bulan ---
  Widget _barChart(KeuanganController c) {
    final data = c.generateMonthlyDataByType();
    final pemasukan = data['Pemasukan']!;
    final pengeluaran = data['Pengeluaran']!;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0');
                if (value % 100000 == 0) {
                  return Text('${(value / 1000).toStringAsFixed(0)}K',
                      style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                if (v < 0 || v > 11) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(months[v.toInt()],
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                  toY: pemasukan[i],
                  color: Colors.green,
                  width: 8,
                  borderRadius: BorderRadius.circular(3)),
              BarChartRodData(
                  toY: pengeluaran[i],
                  color: Colors.red,
                  width: 8,
                  borderRadius: BorderRadius.circular(3)),
            ],
          );
        }),
      ),
    );
  }

  // --- Dialog tambah/edit transaksi ---
  void _showAddDialog(BuildContext context, KeuanganController c,
      [Keuanganmodel? k]) {
    final titleC = TextEditingController(text: k?.title ?? '');
    final amountC =
        TextEditingController(text: k != null ? k.amount.toStringAsFixed(0) : '');
    final type = RxString(k?.type ?? 'Pemasukan');
    final selectedDate = Rx<DateTime?>(k?.date);

    Future<void> _pickDate() async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date != null) selectedDate.value = date;
    }

    Get.defaultDialog(
      title: k == null ? 'Tambah Transaksi' : 'Edit Transaksi',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: amountC,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Obx(() => TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate.value == null
                        ? 'Pilih tanggal'
                        : DateFormat('dd MMM yyyy').format(selectedDate.value!),
                  ),
                  onPressed: _pickDate,
                )),
            const SizedBox(height: 8),
            Obx(() => DropdownButton<String>(
                  value: type.value,
                  isExpanded: true,
                  items: ['Pemasukan', 'Pengeluaran']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) type.value = v;
                  },
                )),
          ],
        ),
      ),
      textCancel: 'Batal',
      textConfirm: 'Simpan',
      onConfirm: () {
        if (titleC.text.trim().isEmpty ||
            amountC.text.trim().isEmpty ||
            selectedDate.value == null) {
          Get.snackbar('Error', 'Semua kolom termasuk tanggal harus diisi');
          return;
        }

        final newData = Keuanganmodel(
          id: k?.id,
          title: titleC.text,
          amount: double.tryParse(amountC.text) ?? 0,
          type: type.value,
          date: selectedDate.value!,
        );

        if (k == null) {
          c.addKeuangan(newData);
        } else {
          c.updateKeuangan(newData);
        }

        Get.back();
      },
    );
  }

  // --- Dialog detail transaksi ---
  void _showDetailDialog(BuildContext context, Keuanganmodel k) {
    Get.defaultDialog(
      title: 'Detail Transaksi',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Judul: ${k.title}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Jumlah: Rp ${k.amount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          Text('Tipe: ${k.type}'),
          const SizedBox(height: 8),
          Text('Tanggal: ${DateFormat('dd MMM yyyy').format(k.date)}'),
        ],
      ),
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
    );
  }
}
