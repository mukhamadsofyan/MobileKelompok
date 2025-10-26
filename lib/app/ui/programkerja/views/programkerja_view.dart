import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/data/models/program_kerja.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';

class ProgramKerjaView extends StatefulWidget {
  final int bidangId;
  final String bidangName;

  const ProgramKerjaView({
    super.key,
    required this.bidangId,
    required this.bidangName,
  });

  @override
  State<ProgramKerjaView> createState() => _ProgramKerjaViewState();
}

class _ProgramKerjaViewState extends State<ProgramKerjaView> {
  final searchCtrl = TextEditingController();
  final controller = Get.find<ProgramController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF8),
      appBar: AppBar(
        title: Text(
          'Program Kerja ${widget.bidangName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Program'),
        onPressed: () => _showAddEditSheet(context, controller),
      ),
      body: Obx(() {
        final filteredList = controller.programList
            .where((p) => p.bidangId == widget.bidangId)
            .where((p) =>
                p.judul.toLowerCase().contains(searchCtrl.text.toLowerCase()))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔍 SEARCH BAR
              TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  hintText: "Cari program kerja...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 📋 LIST PROGRAM
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note_rounded,
                                size: 80, color: Colors.teal.shade200),
                            const SizedBox(height: 14),
                            Text(
                              searchCtrl.text.isEmpty
                                  ? "Belum ada program kerja"
                                  : "Program tidak ditemukan",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (_, i) {
                          final p = filteredList[i];
                          return _AnimatedProgramCard(
                            index: i,
                            child: _ProgramCardItem(
                              program: p,
                              onEdit: () => _showAddEditSheet(
                                  context, controller, program: p),
                              onDelete: () =>
                                  _confirmDelete(context, controller, p),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 🧩 Bottom Sheet Add/Edit
  void _showAddEditSheet(BuildContext context, ProgramController controller,
      {ProgramKerja? program}) {
    final judulCtrl = TextEditingController(text: program?.judul ?? '');
    final deskCtrl = TextEditingController(text: program?.deskripsi ?? '');
    DateTime selectedDate = program?.tanggal ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  program == null
                      ? 'Tambah Program Kerja'
                      : 'Edit Program Kerja',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: judulCtrl,
                  decoration: InputDecoration(
                    labelText: 'Judul Program',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: deskCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                        "Tanggal: ${selectedDate.toLocal().toIso8601String().split('T')[0]}"),
                    const Spacer(),
                    TextButton(
                      child: const Text("Pilih"),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (judulCtrl.text.isEmpty || deskCtrl.text.isEmpty) {
                        Get.snackbar(
                          "Input tidak lengkap",
                          "Mohon isi semua kolom.",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black87,
                        );
                        return;
                      }

                      final data = ProgramKerja(
                        id: program?.id ?? DateTime.now().millisecondsSinceEpoch,
                        bidangId: widget.bidangId,
                        judul: judulCtrl.text,
                        deskripsi: deskCtrl.text,
                        tanggal: selectedDate,
                      );

                      if (program == null) {
                        await controller.addProgram(data);
                        if (context.mounted) Get.back();
                        Get.snackbar(
                          "Berhasil",
                          "Program kerja ditambahkan",
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.black87,
                        );
                      } else {
                        await controller.updateProgram(data);
                        if (context.mounted) Get.back();
                        Get.snackbar(
                          "Berhasil",
                          "Program kerja diperbarui",
                          backgroundColor: Colors.blue.shade100,
                          colorText: Colors.black87,
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Text(program == null ? 'Simpan' : 'Perbarui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🗑️ Konfirmasi Hapus
  void _confirmDelete(
      BuildContext context, ProgramController controller, ProgramKerja program) {
    Get.dialog(
      AlertDialog(
        title: const Text("Hapus Program"),
        content: Text("Yakin ingin menghapus '${program.judul}'?"),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await controller.deleteProgram(program.id);
              Get.back();
              Get.snackbar(
                "Berhasil",
                "Program '${program.judul}' telah dihapus",
                backgroundColor: Colors.red.shade100,
                colorText: Colors.black87,
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}

// 🎞️ Animasi muncul
class _AnimatedProgramCard extends StatelessWidget {
  final Widget child;
  final int index;

  const _AnimatedProgramCard({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// 💠 Kartu Program
class _ProgramCardItem extends StatelessWidget {
  final ProgramKerja program;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProgramCardItem({
    required this.program,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: const Icon(Icons.event, color: Colors.teal)),
        title: Text(program.judul,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(program.deskripsi,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            else if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Edit")
                    ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Hapus")
                    ])),
          ],
        ),
      ),
    );
  }
}
