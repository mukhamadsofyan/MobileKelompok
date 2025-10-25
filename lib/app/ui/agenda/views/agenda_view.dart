import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';
import 'package:orgtrack/app/ui/agenda/controllers/agenda_controller.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final controller = Get.find<AgendaController>();
  final searchCtrl = TextEditingController();
  final filter = "Semua".obs; // 🔘 Filter: Semua, Mendatang, Selesai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF8),
      appBar: AppBar(
        title: const Text(
          'Agenda Organisasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Agenda'),
        onPressed: () => _showAgendaSheet(context),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔍 Filter berdasarkan judul
        var filtered = controller.agendas
            .where((a) => a.title
                .toLowerCase()
                .contains(searchCtrl.text.toLowerCase()))
            .toList();

        // 🎯 Filter tambahan berdasarkan status
        if (filter.value == "Mendatang") {
          filtered = filtered
              .where((a) => a.date.isAfter(DateTime.now()))
              .toList();
        } else if (filter.value == "Selesai") {
          filtered = filtered
              .where((a) => a.date.isBefore(DateTime.now()))
              .toList();
        }

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
                  hintText: "Cari agenda...",
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
              const SizedBox(height: 12),

              // 🏷️ FILTER CHIP
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Semua"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Mendatang"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Selesai"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 📋 LIST AGENDA
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 90, color: Colors.teal.shade200),
                            const SizedBox(height: 10),
                            Text(
                              searchCtrl.text.isEmpty
                                  ? "Belum ada agenda"
                                  : "Agenda tidak ditemukan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          final formattedDate =
                              DateFormat('dd MMM yyyy, HH:mm').format(a.date);
                          final expired = a.date.isBefore(DateTime.now());

                          return TweenAnimationBuilder(
                            duration:
                                Duration(milliseconds: 300 + (i * 80)),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: expired
                                  ? Colors.grey.shade200
                                  : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: expired
                                      ? Colors.grey.shade400
                                      : Colors.teal.shade100,
                                  child: Icon(
                                    expired
                                        ? Icons.event_busy
                                        : Icons.event_available,
                                    color: expired
                                        ? Colors.grey.shade700
                                        : Colors.teal.shade700,
                                  ),
                                ),
                                title: Text(
                                  a.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: expired
                                        ? Colors.grey.shade700
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.description ?? '',
                                        style: TextStyle(
                                          color: expired
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 15,
                                              color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: expired
                                                  ? Colors.grey.shade700
                                                  : Colors.teal.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      _showAgendaSheet(context, agenda: a);
                                    } else if (v == 'delete') {
                                      _confirmDelete(context, a);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.teal),
                                          SizedBox(width: 8),
                                          Text("Edit"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          SizedBox(width: 8),
                                          Text("Hapus"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  // 🟢 Widget Filter Chip
  Widget _buildFilterChip(String label) {
    return Obx(() => ChoiceChip(
          label: Text(label),
          selected: filter.value == label,
          selectedColor: Colors.teal.shade600,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: filter.value == label ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => filter.value = label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: filter.value == label
                  ? Colors.teal.shade600
                  : Colors.grey.shade300,
            ),
          ),
        ));
  }

  // 🧩 Bottom Sheet Add/Edit Agenda
  void _showAgendaSheet(BuildContext context, {AgendaOrganisasi? agenda}) {
    final titleCtrl = TextEditingController(text: agenda?.title ?? '');
    final descCtrl = TextEditingController(text: agenda?.description ?? '');
    final selected = Rxn<DateTime>(agenda?.date);

    Future<void> pickDateTime() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: selected.value ?? now,
        firstDate: now,
        lastDate: DateTime(2100),
      );
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: selected.value != null
              ? TimeOfDay.fromDateTime(selected.value!)
              : TimeOfDay.now(),
        );
        if (time != null) {
          selected.value =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                agenda == null ? "Tambah Agenda" : "Edit Agenda",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Judul Agenda",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() => TextButton.icon(
                    icon: const Icon(Icons.calendar_today,
                        color: Colors.teal),
                    label: Text(
                      selected.value != null
                          ? DateFormat('dd MMM yyyy – HH:mm')
                              .format(selected.value!)
                          : "Pilih Tanggal & Jam",
                      style: const TextStyle(color: Colors.teal),
                    ),
                    onPressed: pickDateTime,
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded),
                  label: Text(agenda == null ? "Simpan" : "Perbarui"),
                  onPressed: () {
                    if (titleCtrl.text.isEmpty ||
                        descCtrl.text.isEmpty ||
                        selected.value == null) {
                      Get.snackbar("Input Tidak Lengkap",
                          "Semua kolom wajib diisi!",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black87);
                      return;
                    }

                    final newAgenda = AgendaOrganisasi(
                      id: agenda?.id,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      date: selected.value!,
                    );

                    if (agenda == null) {
                      controller.addAgenda(newAgenda);
                      Get.snackbar("Berhasil", "Agenda berhasil ditambahkan",
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.black87);
                    } else {
                      controller.updateAgenda(newAgenda);
                      Get.snackbar("Berhasil", "Agenda berhasil diperbarui",
                          backgroundColor: Colors.blue.shade100,
                          colorText: Colors.black87);
                    }

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🗑️ Konfirmasi Hapus
  void _confirmDelete(BuildContext context, AgendaOrganisasi agenda) {
    Get.dialog(AlertDialog(
      title: const Text("Hapus Agenda"),
      content: Text("Apakah kamu yakin ingin menghapus '${agenda.title}'?"),
      actions: [
        TextButton(onPressed: Get.back, child: const Text("Batal")),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            controller.deleteAgenda(agenda.id!);
            Get.back();
            Get.snackbar("Dihapus", "Agenda berhasil dihapus",
                backgroundColor: Colors.orange.shade100,
                colorText: Colors.black87);
          },
          child: const Text("Hapus"),
        ),
      ],
    ));
  }
}
