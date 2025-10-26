import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../data/models/StrukturalModel.dart';
import '../controllers/struktur_controller.dart';

class StrukturKabinetView extends StatefulWidget {
  const StrukturKabinetView({super.key});

  @override
  State<StrukturKabinetView> createState() => _StrukturKabinetViewState();
}

class _StrukturKabinetViewState extends State<StrukturKabinetView> {
  late StrukturalController c;

  @override
  void initState() {
    super.initState();
    // pastikan controller sudah tersedia
    if (!Get.isRegistered<StrukturalController>()) {
      c = Get.put(StrukturalController());
    } else {
      c = Get.find<StrukturalController>();
    }
    c.loadAll();
  }

  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),

      // ===== HEADER APPBAR =====
      appBar: AppBar(
        title: Text(
          'Struktur Kabinet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 5,
        shadowColor: Colors.green.withOpacity(0.4),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onSelected: (value) {
              if (value == 'jabatan') {
                c.list.sort(
                    (a, b) => _jabatanLevel(b.role).compareTo(_jabatanLevel(a.role)));
              } else if (value == 'terbaru') {
                c.list.sort((a, b) => b.id!.compareTo(a.id!));
              } else if (value == 'terlama') {
                c.list.sort((a, b) => a.id!.compareTo(b.id!));
              }
              setState(() {});
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'jabatan', child: Text('Urutkan Jabatan Tertinggi')),
              PopupMenuItem(value: 'terbaru', child: Text('Urutkan Terbaru')),
              PopupMenuItem(value: 'terlama', child: Text('Urutkan Terlama')),
            ],
          ),
        ],
      ),

      // ===== FLOATING ACTION BUTTON =====
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Future.delayed(const Duration(milliseconds: 50), () {
            _showDialog(context, c);
          });
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah'),
        backgroundColor: Colors.green.shade700,
      ),

      // ===== BODY =====
      body: RefreshIndicator(
        onRefresh: () async {
          await c.loadAll();
        },
        child: Column(
          children: [
            // ===== SEARCH BAR =====
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                onChanged: (value) => setState(() => query = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari anggota kabinet...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // ===== LIST ANGGOTA =====
            Expanded(
              child: Obx(() {
                if (c.loading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
                }

                final filtered = c.list.where((s) {
                  return s.name.toLowerCase().contains(query) ||
                      s.role.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada anggota ditemukan 😢',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }

                final gradientColors = [
                  Colors.white,
                  Colors.green.shade50,
                  Colors.white,
                ];

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final s = filtered[index];

                    return FadeInUp(
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      child: GestureDetector(
                        onTap: () => _showDetailFull(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 6,
                                right: 6,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.grey),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('Edit Anggota')),
                                    const PopupMenuItem(
                                        value: 'hapus', child: Text('Hapus Anggota')),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Future.delayed(const Duration(milliseconds: 100),
                                          () {
                                        _showDialog(context, c, s);
                                      });
                                    } else if (value == 'hapus') {
                                      _confirmDelete(context, c, s.id!);
                                    }
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.green.shade100,
                                        child: Text(
                                          s.name.isNotEmpty
                                              ? s.name[0].toUpperCase()
                                              : '?',
                                          style: GoogleFonts.poppins(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        s.name,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        s.role,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.green.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  // === DETAIL FULL SCREEN ===
  void _showDetailFull(Struktural s) {
    final qrData = "ANGGOTA|${s.id}|${s.name}|${s.role}";

    Get.to(() => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Detail Anggota',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.green.shade900,
                    ),
                  ),
                  Text(
                    s.role,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.green.shade100, thickness: 1),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 180,
                            eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: Colors.green.shade800),
                            dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: Colors.green.shade800),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'QR Code Anggota',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kode unik: ${s.id}-${s.name.toUpperCase()}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // === LEVEL JABATAN ===
  int _jabatanLevel(String role) {
    const levels = {
      'Ketua': 5,
      'Wakil Ketua': 4,
      'Sekretaris': 3,
      'Bendahara': 2,
      'Anggota': 1,
    };
    return levels[role] ?? 0;
  }

  // === DIALOG TAMBAH / EDIT ===
// === DIALOG TAMBAH / EDIT ===
void _showDialog(BuildContext context, StrukturalController c, [Struktural? s]) {
  final nameController = TextEditingController(text: s?.name ?? '');
  String selectedRole = s?.role ?? 'Anggota';
  final roles = ['Ketua', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Anggota'];

  bool isSaving = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s == null ? 'Tambah Anggota' : 'Edit Anggota',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Jabatan',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: roles
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectedRole = value;
                    },
                  ),
                  const SizedBox(height: 20),

                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: CircularProgressIndicator(color: Colors.green),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    Get.snackbar(
                                      'Perhatian',
                                      'Nama tidak boleh kosong',
                                      backgroundColor: Colors.orange.shade100,
                                      colorText: Colors.orange.shade900,
                                      snackPosition: SnackPosition.TOP, // ✅ atas
                                    );
                                    return;
                                  }

                                  setState(() => isSaving = true);

                                  try {
                                    if (s == null) {
                                      await c.addStruktural(name, selectedRole);
                                      Get.snackbar(
                                        'Berhasil',
                                        'Anggota baru berhasil ditambahkan!',
                                        backgroundColor: Colors.green.shade100,
                                        colorText: Colors.green.shade900,
                                        snackPosition: SnackPosition.TOP, // ✅ atas
                                      );
                                    } else {
                                      await c.updateStruktural(Struktural(
                                          id: s.id, name: name, role: selectedRole));
                                      Get.snackbar(
                                        'Berhasil',
                                        'Data anggota berhasil diperbarui!',
                                        backgroundColor: Colors.green.shade100,
                                        colorText: Colors.green.shade900,
                                        snackPosition: SnackPosition.TOP, // ✅ atas
                                      );
                                    }

                                    await c.loadAll();
                                    Navigator.pop(dialogContext); // auto close
                                  } catch (e) {
                                    setState(() => isSaving = false);
                                    Get.snackbar(
                                      'Gagal',
                                      'Terjadi kesalahan: $e',
                                      backgroundColor: Colors.red.shade100,
                                      colorText: Colors.red.shade900,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  }
                                },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
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
      );
    },
  );
}

// === KONFIRMASI HAPUS AUTO-CLOSE + NOTIF ATAS SAJA ===
void _confirmDelete(BuildContext context, StrukturalController c, int id) {
  Get.defaultDialog(
    title: 'Hapus Anggota',
    middleText: 'Apakah Anda yakin ingin menghapus anggota ini?',
    textCancel: 'Batal',
    textConfirm: 'Hapus',
    confirmTextColor: Colors.white,
    buttonColor: Colors.red.shade400,
    onConfirm: () async {
      try {
        Get.back(); // tutup dialog konfirmasi
        await c.deleteStrukturalById(id);
        await c.loadAll();

        // Snackbar atas saja
        Get.snackbar(
          'Terhapus',
          'Data anggota berhasil dihapus!',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP, // ✅ atas
        );
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat menghapus: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }
    },
  );
}


}
