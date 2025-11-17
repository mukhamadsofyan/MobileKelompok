import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Organisasi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.reports.isEmpty) {
            return const Center(child: Text('Belum ada laporan.'));
          }

          return ListView.builder(
            itemCount: controller.reports.length,
            itemBuilder: (context, index) {
              final report = controller.reports[index];

              return Card(
                child: ListTile(
                  title: Text(report.judul),
                  subtitle: Text(report.tanggal),

                  // EDIT
                  onTap: () => _showEditDialog(context, index, report),

                  // DELETE
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.hapusLaporan(index),
                  ),
                ),
              );
            },
          );
        }),
      ),

      // ADD
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  // ========================================================
  //                 POPUP TAMBAH LAPORAN
  // ========================================================
  void _showAddDialog(BuildContext context) {
    final judulCtrl = TextEditingController();
    final tanggalCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split("T").first,
    );

    // fungsi pilih tanggal
    Future<void> pilihTanggal() async {
      final DateTime? picked = await showDatePicker(
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
            onTap: pilihTanggal,
          ),
        ],
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      onConfirm: () {
        if (judulCtrl.text.isNotEmpty) {
          controller.tambahLaporan(judulCtrl.text, tanggalCtrl.text);
          Get.back();
        }
      },
    );
  }

  // ========================================================
  //                    POPUP EDIT LAPORAN
  // ========================================================
  void _showEditDialog(BuildContext context, int index, report) {
    final judulCtrl = TextEditingController(text: report.judul);
    final tanggalCtrl = TextEditingController(text: report.tanggal);

    Future<void> pilihTanggal() async {
      final DateTime? picked = await showDatePicker(
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
            onTap: pilihTanggal,
          ),
        ],
      ),
      textConfirm: "Update",
      textCancel: "Batal",
      onConfirm: () {
        if (judulCtrl.text.isNotEmpty) {
          controller.editLaporan(index, judulCtrl.text, tanggalCtrl.text);
          Get.back();
        }
      },
    );
  }
}
