import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/bidang/controllers/bidang_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
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
      _fetchData();
    });

    ever<FetchMode>(modeC.mode, (_) {
      _fetchData();
    });
  }

  // ============================================================
  // FETCH + NOTIFIKASI (PINDAH KE ATAS)
  // ============================================================
  void _fetchData() async {
    if (modeC.mode.value == FetchMode.http) {
      await httpC.fetchBidang();
    } else {
      await dioC.fetchBidang();
    }

    if (!mounted) return;
  }

  // ============================================================
  // HEADER GRADIENT
  // ============================================================
  List<Color> _headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const [
            Color(0xFF004D40),
            Color(0xFF00695C),
            Color(0xFF00796B),
          ]
        : const [
            Color(0xFF009688),
            Color(0xFF4DB6AC),
            Color(0xFF80CBC4),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    final bg = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: bg,
      body: Obx(() {
        final isHttp = modeC.mode.value == FetchMode.http;
        final list = isHttp ? httpC.bidangList : dioC.bidangList;
        final loading = isHttp ? httpC.loadingBidang : dioC.loadingBidang;

        if (loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Container(
              padding: const EdgeInsets.only(
                  top: 45, left: 20, right: 20, bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _headerGradient(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW HEADER
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
                      Row(
                        children: [
                          Obx(() {
                            return IconButton(
                              icon: Icon(
                                themeC.isDark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: Colors.white,
                              ),
                              onPressed: () => themeC.toggleTheme(),
                            );
                          }),
                          const SizedBox(width: 6),
                          Obx(() {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<FetchMode>(
                                value: modeC.mode.value,
                                underline: const SizedBox(),
                                dropdownColor: cardColor,
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
                                onChanged: (v) {
                                  if (v != null) modeC.mode.value = v;
                                },
                              ),
                            );
                          }),
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
                    ),
                    child: TextField(
                      style: TextStyle(color: textColor),
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

            // ============================================================
            // LIST
            // ============================================================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      title: Text(
                        b.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
