import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:orgtrack/app/ui/bidang/controllers/bidang_controller.dart';
import '../../programkerja/views/programkerja_view.dart';

class BidangView extends StatelessWidget {
  BidangView({super.key});

  final controller = Get.find<BidangControllerSupabase>();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    final colorBG = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final colorText = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.teal.shade600,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddDialog(context),
            )
          : null,

      backgroundColor: colorBG,

      body: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = controller.bidangList;

          return Column(
            children: [
              _header(themeC, colorText, cardColor),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final b = list[i];
                    return _bidangCard(context, b, colorText, cardColor);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ===============================================================
  // HEADER DENGAN TOGGLE DARK/LIGHT
  // ===============================================================
  Widget _header(ThemeController themeC, Color colorText, Color cardColor) {
    return Container(
      padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 25),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeC.isDark ? 0.40 : 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BACK
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
          ),

          // TITLE
          const Text(
            "Daftar Bidang",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          // TOGGLE THEME
          IconButton(
            icon: Icon(
              themeC.isDark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => themeC.toggleTheme(),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CARD BIDANG + ADMIN CRUD PROTECTION
  // ===============================================================
  Widget _bidangCard(BuildContext context, dynamic b, Color textColor, Color cardColor) {
    final bool isAdmin = auth.isAdmin;

    return GestureDetector(
      onTap: () {
        Get.to(() => ProgramKerjaView(
              bidangId: b.id,
              bidangName: b.nama,
            ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // KIRI (ICON + TEXT)
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.teal.shade100.withOpacity(0.7),
                  child:
                      const Icon(Icons.workspaces_outline, color: Colors.teal),
                ),

                const SizedBox(width: 14),

                Hero(
                  tag: "title_${b.id}",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      b.nama,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // KANAN (ADMIN ONLY)
            Row(
              children: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showEditDialog(context, b.id!, b.nama),
                  ),

                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Hapus Bidang",
                        middleText: "Yakin hapus \"${b.nama}\"?",
                        textCancel: "Batal",
                        textConfirm: "Hapus",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.deleteBidang(b.id!);
                          Get.back();
                        },
                      );
                    },
                  ),

                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // DIALOG TAMBAH (ADMIN ONLY)
  // ===============================================================
  void _showAddDialog(BuildContext context) {
    if (!auth.isAdmin) {
      Get.snackbar("Akses Ditolak", "Hanya admin yang bisa menambah bidang");
      return;
    }

    final nameC = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Bidang"),
        content: TextField(
          controller: nameC,
          decoration: const InputDecoration(
            labelText: "Nama Bidang",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (nameC.text.isNotEmpty) {
                controller.addBidang(nameC.text);
                Get.back();
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  // ===============================================================
  // DIALOG EDIT (ADMIN ONLY)
  // ===============================================================
  void _showEditDialog(BuildContext context, int id, String nama) {
    if (!auth.isAdmin) {
      Get.snackbar("Akses Ditolak", "Hanya admin yang bisa mengedit bidang");
      return;
    }

    final nameC = TextEditingController(text: nama);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Bidang"),
        content: TextField(
          controller: nameC,
          decoration: const InputDecoration(
            labelText: "Nama Bidang",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              controller.updateBidang(id, nameC.text);
              Get.back();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
