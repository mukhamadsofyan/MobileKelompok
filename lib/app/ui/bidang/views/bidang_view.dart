import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/bidang/controllers/bidang_controller.dart';
import '../controllers/bidang_controller_http.dart';
import '../controllers/bidang_controller_dio.dart';
import '../../programkerja/views/programkerja_view.dart';

class BidangView extends StatefulWidget {
  const BidangView({super.key});

  @override
  State<BidangView> createState() => _BidangViewState();
}

class _BidangViewState extends State<BidangView> {
  late final BidangControllerHttp httpC;
  late final BidangControllerDio dioC;
  late final ModeControllerBidang modeC;

  @override
  void initState() {
    super.initState();
    httpC = Get.put(BidangControllerHttp());
    dioC = Get.put(BidangControllerDio());
    modeC = Get.put(ModeControllerBidang());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modeC.mode.value == FetchMode.http)
        httpC.fetchBidang();
      else
        dioC.fetchBidang();
    });

    ever<FetchMode>(modeC.mode, (m) {
      if (m == FetchMode.http)
        httpC.fetchBidang();
      else
        dioC.fetchBidang();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Obx(() {
        final isHttp = modeC.mode.value == FetchMode.http;
        final list = isHttp ? httpC.bidangList : dioC.bidangList;
        final loading = isHttp ? httpC.loadingBidang : dioC.loadingBidang;

        if (loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // ================== HEADER GRADIENT ==================
            Container(
              padding: const EdgeInsets.only(
                  top: 45, left: 20, right: 20, bottom: 12),
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
                  // ← Back + Title + Filter button (sejajar seperti Struktur)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const Text(
                        "Bidang",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),

                      // Dropdown Mode (HTTP / DIO)
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<FetchMode>(
                              value: modeC.mode.value,
                              underline: const SizedBox(),
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.expand_more,
                                  color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                  value: FetchMode.http,
                                  child: Text("HTTP"),
                                ),
                                DropdownMenuItem(
                                  value: FetchMode.dio,
                                  child: Text("DIO"),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) modeC.mode.value = val;
                              },
                            ),
                          )),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ================= SEARCH BAR =================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      decoration: InputDecoration(
                        hintText: "Cari bidang...",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.teal),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST BIDANG =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      title: Text(
                        b.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.to(() => ProgramKerjaView(
                              bidangId: b.id,
                              bidangName: b.nama,
                            ));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
