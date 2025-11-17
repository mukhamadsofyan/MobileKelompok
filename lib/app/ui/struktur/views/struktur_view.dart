import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
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
    if (!Get.isRegistered<StrukturalController>()) {
      c = Get.put(StrukturalController());
    } else {
      c = Get.find<StrukturalController>();
    }
    c.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>(); // akses admin
    final themeC = Get.find<ThemeController>();

    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
      body: Column(
        children: [
          // ==================== HEADER GRADIENT ====================
          Container(
            padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
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
                  color: Colors.black.withOpacity(themeC.isDark ? 0.4 : 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // ==================== TOP BAR ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Struktur Kabinet",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        // ====== TOGGLE THEME ======
                        IconButton(
                          icon: Icon(
                            themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () => themeC.toggleTheme(),
                        ),

                        // ====== FILTER MENU ======
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_alt_rounded,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            if (value == 'jabatan') {
                              c.list.sort((a, b) => _jabatanLevel(b.role)
                                  .compareTo(_jabatanLevel(a.role)));
                            } else if (value == 'terbaru') {
                              c.list.sort((a, b) => b.id!.compareTo(a.id!));
                            } else if (value == 'terlama') {
                              c.list.sort((a, b) => a.id!.compareTo(b.id!));
                            }
                            setState(() {});
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'jabatan',
                                child: Text("Jabatan Tertinggi")),
                            PopupMenuItem(
                                value: 'terbaru', child: Text("Terbaru")),
                            PopupMenuItem(
                                value: 'terlama', child: Text("Terlama")),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ============== SEARCH BAR CLEAN (IKUT TEMA) ==============
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(themeC.isDark ? 0.5 : 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => query = value.toLowerCase()),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      hintText: "Cari anggota kabinet...",
                      prefixIcon:
                          Icon(Icons.search, color: colorText.withOpacity(0.6)),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorText.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),

          // ==================== LIST GRID ====================
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
                      fontSize: 16,
                      color: colorText.withOpacity(0.6),
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final s = filtered[index];

                  return FadeInUp(
                    duration: Duration(milliseconds: 400 + (index * 45)),
                    child: GestureDetector(
                      onTap: () => _showDetailFull(s),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: themeC.isDark ? cardColor : null,
                          gradient: themeC.isDark
                              ? null
                              : LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.teal.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: colorText.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: themeC.isDark
                                  ? Colors.teal.shade900.withOpacity(0.45)
                                  : Colors.teal.shade100,
                              child: Text(
                                s.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: themeC.isDark
                                      ? Colors.teal.shade200
                                      : Colors.teal.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              s.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: colorText,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              s.role,
                              style: GoogleFonts.poppins(
                                color: themeC.isDark
                                    ? Colors.teal.shade200
                                    : Colors.teal.shade700,
                                fontSize: 13,
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

      // ============== FAB ONLY ADMIN ==============
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Tambah",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _showDialog(context, c),
            )
          : null,
    );
  }

  // ==================== DETAIL QR ====================
  void _showDetailFull(Struktural s) {
    final qrData = "ANGGOTA|${s.id}|${s.name}|${s.role}";
    final themeC = Get.find<ThemeController>();
    final context = Get.context!;
    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;

    Get.to(() => Scaffold(
          backgroundColor: colorBG,
          appBar: AppBar(
            title: Text("Detail Anggota", style: GoogleFonts.poppins()),
            backgroundColor:
                themeC.isDark ? Colors.teal.shade900 : Colors.teal.shade700,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FOTO / INITIAL
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: themeC.isDark
                        ? Colors.teal.shade900.withOpacity(0.45)
                        : Colors.teal.shade100,
                    child: Text(
                      s.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: themeC.isDark
                            ? Colors.teal.shade200
                            : Colors.teal.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NAMA
                  Text(
                    s.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: colorText,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // JABATAN
                  Text(
                    s.role,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: themeC.isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // QR CODE
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: themeC.isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade700,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: themeC.isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade700,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

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

  // ==================== DIALOG TAMBAH/EDIT ====================
  void _showDialog(BuildContext context, StrukturalController c,
      [Struktural? s]) {
    final themeC = Get.find<ThemeController>();
    final cardColor = Theme.of(context).cardColor;
    final colorText = Theme.of(context).colorScheme.onBackground;

    final nameC = TextEditingController(text: s?.name ?? '');
    String selectedRole = s?.role ?? 'Anggota';

    final roles = [
      'Ketua',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Anggota'
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s == null ? "Tambah Anggota" : "Edit Anggota",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: themeC.isDark
                        ? Colors.teal.shade200
                        : Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 18),

                // NAMA
                TextField(
                  controller: nameC,
                  style: TextStyle(color: colorText),
                  decoration: InputDecoration(
                    labelText: "Nama",
                    labelStyle: TextStyle(color: colorText.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.person_outline,
                        color: colorText.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField(
                  value: selectedRole,
                  dropdownColor: cardColor,
                  decoration: InputDecoration(
                    labelText: "Jabatan",
                    labelStyle: TextStyle(color: colorText.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.badge_outlined,
                        color: colorText.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: roles
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (v) => selectedRole = v.toString(),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorText,
                          side: BorderSide(
                            color: colorText.withOpacity(0.4),
                          ),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameC.text.trim();

                          if (name.isEmpty) {
                            Get.snackbar(
                              "Peringatan",
                              "Nama tidak boleh kosong",
                              backgroundColor: Colors.orange.shade100
                                  .withOpacity(themeC.isDark ? 0.2 : 1),
                              colorText: Colors.orange.shade800,
                            );
                            return;
                          }

                          if (s == null) {
                            await c.addStruktural(name, selectedRole);
                          } else {
                            await c.updateStruktural(Struktural(
                              id: s.id,
                              name: name,
                              role: selectedRole,
                            ));
                          }

                          await c.loadAll();
                          Get.back();
                        },
                        child: const Text(
                          "Simpan",
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
  }
}
