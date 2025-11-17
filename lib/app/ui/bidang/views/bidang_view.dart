import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/bidang/controllers/bidang_controller.dart';
import '../../programkerja/views/programkerja_view.dart';

class BidangView extends StatelessWidget {
  BidangView({super.key});

  final controller = Get.put(BidangControllerSupabase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(context),
      ),
      backgroundColor: const Color(0xFFF3F6F7),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = controller.bidangList;

        return Column(
          children: [
            // ===================== HEADER =====================
            _header(),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];

                  return _bidangCard(context, b);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // ============================================================
  //                          HEADER
  // ============================================================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF009688),
            Color(0xFF4DB6AC),
            Color(0xFF80CBC4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 22),
              ),
              const Text(
                "Daftar Bidang",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 20),

          // SEARCH BOX
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Cari bidang...",
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //                    CARD BIDANG BARU (MODERN)
  // ============================================================
Widget _bidangCard(BuildContext context, dynamic b) {
  return GestureDetector(
    onTap: () {
      Get.to(() => ProgramKerjaView(
            bidangId: b.id,
            bidangName: b.nama,
          ));
    },

    child: Hero(
      tag: "bidang_${b.id}",
      flightShuttleBuilder: (_, animation, __, ___, ____) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeOut),
          ),
          child: Material(
            color: Colors.transparent,
            child: Text(
              b.nama,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT SIDE
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.workspaces_outline,
                      color: Colors.teal, size: 22),
                ),
                const SizedBox(width: 14),

                // TEXT HERO AREA
                Hero(
                  tag: "title_${b.id}",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      b.nama,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // RIGHT SIDE (edit, delete, arrow)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditDialog(context, b.id!, b.nama),
                ),
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

                AnimatedOpacity(
                  opacity: 0.8,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  // ============================================================
  //                        DIALOG TAMBAH
  // ============================================================
  void _showAddDialog(BuildContext context) {
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
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (nameC.text.isNotEmpty) {
                controller.addBidang(nameC.text);
                Get.back();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //                        DIALOG EDIT
  // ============================================================
  void _showEditDialog(BuildContext context, int id, String nama) {
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
              if (nameC.text.isNotEmpty) {
                controller.updateBidang(id, nameC.text);
                Get.back();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
