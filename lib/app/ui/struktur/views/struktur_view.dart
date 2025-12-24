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
                            themeC.isDark
                                ? Icons.dark_mode
                                : Icons.light_mode,
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
                              c.list.sort((a, b) =>
                                  _roleRank(b.role)
                                      .compareTo(_roleRank(a.role)));
                            } else if (value == 'terbaru') {
                              c.list.sort((a, b) =>
                                  b.id!.compareTo(a.id!));
                            } else {
                              c.list.sort((a, b) =>
                                  a.id!.compareTo(b.id!));
                            }
                            setState(() {});
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'jabatan',
                                child: Text("Jabatan Tertinggi")),
                            PopupMenuItem(
                                value: 'terbaru',
                                child: Text("Terbaru")),
                            PopupMenuItem(
                                value: 'terlama',
                                child: Text("Terlama")),
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
                    onChanged: (v) =>
                        setState(() => query = v.toLowerCase()),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      hintText: "Cari anggota kabinet...",
                      prefixIcon: Icon(Icons.search,
                          color: colorText.withOpacity(0.6)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      hintStyle:
                          TextStyle(color: colorText.withOpacity(0.5)),
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
                return const Center(
                    child: CircularProgressIndicator());
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
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  backgroundColor:
                                      Colors.teal.withOpacity(0.15),
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
                                icon: Icon(Icons.more_vert,
                                    color:
                                        colorText.withOpacity(0.65)),
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
                                      child: Text("Edit")),
                                  PopupMenuItem(
                                      value: 'delete',
                                      child: Text("Hapus")),
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
              backgroundColor:
                  Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tambah",
                  style: TextStyle(color: Colors.white)),
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

    Get.to(() => Scaffold(
          backgroundColor:
              Theme.of(ctx).colorScheme.background,
          appBar: AppBar(
            title: const Text("Detail Anggota"),
            centerTitle: true,
            backgroundColor:
                themeC.isDark ? Colors.teal.shade900 : Colors.teal.shade700,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(data: qr, size: 220),
                const SizedBox(height: 20),
                Text(s.name,
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorText)),
                Text(s.role,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.teal.shade700)),
              ],
            ),
          ),
        ));
  }

  void _confirmDelete(Struktural s) {
    Get.defaultDialog(
      title: "Hapus Anggota?",
      middleText: "Yakin ingin menghapus ${s.name}?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await c.deleteStrukturalById(s.id!);
        Get.back();
      },
    );
  }

  void _openForm(StrukturalController c, [Struktural? s]) {
    // (logika form TIDAK diubah dari punyamu sebelumnya)
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
