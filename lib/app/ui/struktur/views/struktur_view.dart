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
    final auth = Get.find<AuthController>();
    final themeC = Get.find<ThemeController>();

    final colorBG = Theme.of(context).colorScheme.background;
    final colorText = Theme.of(context).colorScheme.onBackground;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: colorBG,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Struktur Kabinet",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
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
                          icon: const Icon(Icons.filter_alt_rounded,
                              color: Colors.white),
                          onSelected: (value) {
                            if (value == 'jabatan') {
                              c.list.sort((a, b) => _roleRank(b.role)
                                  .compareTo(_roleRank(a.role)));
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

                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => query = value.toLowerCase()),
                    style: TextStyle(color: colorText),
                    decoration: InputDecoration(
                      hintText: "Cari anggota kabinet...",
                      prefixIcon:
                          Icon(Icons.search, color: colorText.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      hintStyle: TextStyle(color: colorText.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ================= LIST =================
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

                  return FadeInUp(
                    duration: Duration(milliseconds: 400 + index * 45),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // CARD UTAMA (tetap full size)
                            GestureDetector(
                              onTap: () => _showDetail(s),
                              child: Container(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: themeC.isDark
                                      ? null
                                      : LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.teal.shade50
                                          ],
                                        ),
                                  color: themeC.isDark ? cardColor : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 34,
                                      backgroundColor: themeC.isDark
                                          ? Colors.teal.shade900
                                              .withOpacity(0.4)
                                          : Colors.teal.shade100,
                                      child: Text(
                                        s.name[0].toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
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

                            // MENU TITIK TIGA
                            if (auth.isAdmin)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: colorText.withOpacity(0.65),
                                      size: 22),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openForm(c, s);
                                    } else if (value == 'delete') {
                                      _confirmDelete(s);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit', child: Text("Edit")),
                                    PopupMenuItem(
                                        value: 'delete', child: Text("Hapus")),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ================= FAB (Admin Only) =================
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text("Tambah", style: TextStyle(color: Colors.white)),
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
          backgroundColor: Theme.of(ctx).colorScheme.background,
          appBar: AppBar(
            title: const Text("Detail Anggota"),
            centerTitle: true,
            backgroundColor:
                themeC.isDark ? Colors.teal.shade900 : Colors.teal.shade700,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: themeC.isDark
                        ? Colors.teal.shade900.withOpacity(0.45)
                        : Colors.teal.shade100,
                    child: Text(
                      s.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: themeC.isDark
                            ? Colors.teal.shade200
                            : Colors.teal.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    s.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: colorText,
                    ),
                  ),
                  Text(
                    s.role,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: themeC.isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade700,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // QR CODE
                  QrImageView(
                    data: qr,
                    size: 230,
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

  // ================= DELETE CONFIRM =================
  void _confirmDelete(Struktural s) {
    Get.defaultDialog(
      title: "Hapus Anggota?",
      middleText: "Yakin ingin menghapus ${s.name}?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        final c = Get.find<StrukturalController>();
        await c.deleteStrukturalById(s.id!);
        Get.back(); // close dialog
      },
    );
  }

  // ================= FORM TAMBAH / EDIT =================
  void _openForm(StrukturalController c, [Struktural? s]) {
    final themeC = Get.find<ThemeController>();
    final ctx = Get.context!;
    final colorText = Theme.of(ctx).colorScheme.onBackground;
    final cardColor = Theme.of(ctx).cardColor;

    final nameC = TextEditingController(text: s?.name ?? '');
    String role = s?.role ?? "Anggota";

    final roles = [
      'Ketua',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Anggota'
    ];

    showDialog(
      context: ctx,
      builder: (_) {
        return Dialog(
          backgroundColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

                // NAMA INPUT
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

                // ROLE DROPDOWN
                DropdownButtonFormField(
                  value: role,
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
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, style: TextStyle(color: colorText)),
                          ))
                      .toList(),
                  onChanged: (v) => role = v.toString(),
                ),

                const SizedBox(height: 20),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorText.withOpacity(0.4)),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(ctx).colorScheme.primary,
                        ),
                        child: const Text("Simpan",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final name = nameC.text.trim();

                          if (name.isEmpty) {
                            Get.snackbar(
                                "Peringatan", "Nama tidak boleh kosong");
                            return;
                          }

                          if (s == null) {
                            await c.addStruktural(name, role);
                          } else {
                            await c.updateStruktural(Struktural(
                              id: s.id,
                              name: name,
                              role: role,
                            ));
                          }

                          await c.loadAll();
                          Get.back();
                        },
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

  // ================= ROLE RANK =================
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
