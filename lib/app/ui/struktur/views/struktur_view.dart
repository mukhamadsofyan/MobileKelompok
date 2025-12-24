import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/StrukturalModel.dart';
import '../controllers/struktur_controller.dart';
import '../../../controllers/auth_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';

class StrukturKabinetView extends StatefulWidget {
  const StrukturKabinetView({super.key});

  @override
  State<StrukturKabinetView> createState() => _StrukturKabinetViewState();
}

class _StrukturKabinetViewState extends State<StrukturKabinetView> {
  late StrukturalController c;
  String query = '';

  @override
  void initState() {
    super.initState();
    c = Get.put(StrukturalController());
    c.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeC = Get.find<ThemeController>();

    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
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
                // TOP BAR
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
                      "Struktur Kabinet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // ACTIONS
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
                          onSelected: (value) {
                            if (value == 'jabatan') {
                              c.list.sort(
                                (a, b) => _roleRank(
                                  b.role,
                                ).compareTo(_roleRank(a.role)),
                              );
                            } else if (value == 'terbaru') {
                              c.list.sort((a, b) => b.id!.compareTo(a.id!));
                            } else {
                              c.list.sort((a, b) => a.id!.compareTo(b.id!));
                            }
                            setState(() {});
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'jabatan',
                              child: Text("Jabatan Tertinggi"),
                            ),
                            PopupMenuItem(
                              value: 'terbaru',
                              child: Text("Terbaru"),
                            ),
                            PopupMenuItem(
                              value: 'terlama',
                              child: Text("Terlama"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // SEARCH BAR
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
                    onChanged: (v) => setState(() => query = v.toLowerCase()),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      hintText: "Cari anggota kabinet...",
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorText.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      hintStyle: TextStyle(color: colorText.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================== LIST =====================
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = c.list.where((s) {
                return s.name.toLowerCase().contains(query) ||
                    s.role.toLowerCase().contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    "Tidak ada anggota ditemukan",
                    style: GoogleFonts.poppins(
                      color: colorText.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final s = filtered[index];

                  return GestureDetector(
                    onTap: () => _showDetail(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.teal.withOpacity(
                                    0.15,
                                  ),
                                  child: Text(
                                    s.name[0].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  s.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: colorText,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  s.role,
                                  style: GoogleFonts.poppins(
                                    color: Colors.teal.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // MENU ADMIN
                          if (auth.isAdmin)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: colorText.withOpacity(0.65),
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openForm(c, s);
                                  } else if (value == 'delete') {
                                    _confirmDelete(s);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Hapus"),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Tambah",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _openForm(c),
            )
          : null,
    );
  }

  // ================= DETAIL =================
  void _showDetail(Struktural s) {
    final themeC = Get.find<ThemeController>();
    final ctx = Get.context!;
    final colorText = Theme.of(ctx).colorScheme.onBackground;

    final qr = "ANGGOTA|${s.id}|${s.name}|${s.role}";

    Get.to(
      () => Scaffold(
        backgroundColor: Theme.of(ctx).colorScheme.background,
        appBar: AppBar(
          title: const Text("Detail Anggota"),
          centerTitle: true,
          backgroundColor: themeC.isDark
              ? Colors.teal.shade900
              : Colors.teal.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: qr, size: 220),
              const SizedBox(height: 20),
              Text(
                s.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorText,
                ),
              ),
              Text(
                s.role,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Struktural s) {
    // ================= VALIDASI AKSES =================
    if (!Get.find<AuthController>().isAdmin) {
      Get.snackbar(
        "Akses Ditolak",
        "Hanya admin yang bisa menghapus anggota",
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
                "Hapus Anggota",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // ================= CONTENT =================
              Text(
                "Apakah kamu yakin ingin menghapus anggota\n“${s.name}” ?",
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
                        // ================= TUTUP DIALOG DULU =================
                        Get.back();

                        await c.deleteStrukturalById(s.id!);

                        // ================= NOTIFIKASI BERHASIL =================
                        Get.snackbar(
                          "Berhasil",
                          "Anggota berhasil dihapus",
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

  void _openForm(StrukturalController c, [Struktural? s]) {
    final nameC = TextEditingController(text: s?.name ?? '');

    final roles = [
      'Ketua',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Anggota',
    ];

    String? selectedRole = s?.role;

    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
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
                          Icons.badge_outlined,
                          color: Colors.teal,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s == null
                                ? "Tambah Anggota Kabinet"
                                : "Edit Anggota Kabinet",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Lengkapi data anggota dengan benar",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= NAMA =================
                  Text(
                    "Nama Anggota",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameC,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "Contoh: Ahmad Sofyan",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= JABATAN =================
                  Text(
                    "Jabatan",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: "Pilih jabatan",
                      prefixIcon: const Icon(Icons.workspace_premium_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: roles
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: r == 'Ketua'
                                      ? Colors.redAccent
                                      : r == 'Wakil Ketua'
                                      ? Colors.orange
                                      : Colors.teal,
                                ),
                                const SizedBox(width: 10),
                                Text(r),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      selectedRole = v;
                    },
                  ),

                  const SizedBox(height: 36),

                  // ================= BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        s == null ? "SIMPAN DATA" : "UPDATE DATA",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (nameC.text.trim().isEmpty || selectedRole == null) {
                          Get.snackbar(
                            "Peringatan",
                            "Nama dan jabatan wajib diisi",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // Tutup bottom sheet dulu
                        Get.back();

                        if (s == null) {
                          await c.addStruktural(
                            nameC.text.trim(),
                            selectedRole!,
                          );

                          Get.snackbar(
                            "Berhasil",
                            "Anggota berhasil ditambahkan",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          await c.updateStruktural(
                            Struktural(
                              id: s.id,
                              name: nameC.text.trim(),
                              role: selectedRole!,
                            ),
                          );

                          Get.snackbar(
                            "Berhasil",
                            "Data anggota berhasil diperbarui",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
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

  int _roleRank(String role) {
    const level = {
      'Ketua': 5,
      'Wakil Ketua': 4,
      'Sekretaris': 3,
      'Bendahara': 2,
      'Anggota': 1,
    };
    return level[role] ?? 0;
  }
}
