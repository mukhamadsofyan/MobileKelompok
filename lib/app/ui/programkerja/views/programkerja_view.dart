import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_dio.dart';
import '../controllers/program_kerja_mode.dart';

class ProgramKerjaView extends StatefulWidget {
  final int bidangId;
  final String bidangName;

  const ProgramKerjaView({
    super.key,
    required this.bidangId,
    required this.bidangName,
  });

  @override
  State<ProgramKerjaView> createState() => _ProgramKerjaViewState();
}

class _ProgramKerjaViewState extends State<ProgramKerjaView> {
  late final ProgramControllerHttp httpC;
  late final ProgramControllerDio dioC;
  late final ModeController modeC;

  // search
  final RxString q = "".obs;

  @override
  void initState() {
    super.initState();
    httpC = Get.put(ProgramControllerHttp());
    dioC = Get.put(ProgramControllerDio());
    modeC = Get.put(ModeController());

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    ever<FetchMode>(modeC.mode, (_) => _fetch());
  }

  void _fetch() {
    if (modeC.mode.value == FetchMode.http) {
      httpC.fetchProgramByBidang(widget.bidangId);
    } else {
      dioC.fetchProgramByBidang(widget.bidangId);
    }
  }

  // sama persis seperti Bidang (gradient teal)
  List<Color> _headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00796B)]
        : const [Color(0xFF009688), Color(0xFF4DB6AC), Color(0xFF80CBC4)];
  }

  List _filterList(List list) {
    final keyword = q.value.trim().toLowerCase();
    if (keyword.isEmpty) return list;

    return list.where((p) {
      final judul = (p.judul ?? "").toString().toLowerCase();
      final desk = (p.deskripsi ?? "").toString().toLowerCase();
      return judul.contains(keyword) || desk.contains(keyword);
    }).toList();
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

        final listRaw = isHttp ? httpC.programList : dioC.programList;
        final loading = isHttp ? httpC.loadingProgram : dioC.loadingProgram;

        final list = _filterList(listRaw);

        if (loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // ==========================================================
            // HEADER (SAMA POLA DENGAN BIDANG)
            // ==========================================================
            Container(
              padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 12),
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
                  // row atas: back - title - actions (theme + dropdown)
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

                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Program Kerja",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.bidangName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          // toggle theme (sama seperti Bidang)
                          Obx(() {
                            return IconButton(
                              icon: Icon(
                                themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                                size: 26,
                                color: Colors.white,
                              ),
                              onPressed: () => themeC.toggleTheme(),
                            );
                          }),

                          const SizedBox(width: 6),

                          // mode dropdown pill (sama seperti Bidang)
                          Obx(() {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<FetchMode>(
                                value: modeC.mode.value,
                                underline: const SizedBox(),
                                dropdownColor: cardColor,
                                icon: const Icon(Icons.expand_more, color: Colors.white),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                items: const [
                                  DropdownMenuItem(value: FetchMode.http, child: Text("HTTP")),
                                  DropdownMenuItem(value: FetchMode.dio, child: Text("DIO")),
                                ],
                                onChanged: (val) {
                                  if (val != null) modeC.mode.value = val;
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // search bar pill (sama seperti Bidang)
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.10,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(color: textColor),
                      onChanged: (v) => q.value = v,
                      decoration: InputDecoration(
                        hintText: "Cari program kerja...",
                        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.search, color: Colors.teal),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        suffixIcon: Obx(() {
                          if (q.value.isEmpty) return const SizedBox();
                          return IconButton(
                            icon: Icon(Icons.close_rounded, color: textColor.withOpacity(0.8)),
                            onPressed: () {
                              q.value = "";
                              FocusScope.of(context).unfocus();
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // LIST PROGRAM KERJA (CARD STYLE KAYAK BIDANG)
            // ==========================================================
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        q.value.isEmpty ? "Belum ada program kerja" : "Tidak ada hasil pencarian",
                        style: TextStyle(color: textColor.withOpacity(0.85)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];

                        return Card(
                          color: cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            title: Text(
                              (p.judul ?? "-").toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                (p.deskripsi ?? "").toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.75),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: textColor.withOpacity(0.7),
                            ),
                            onTap: () {
                              // kalau kamu punya halaman detail, taruh di sini
                              // Get.to(() => ProgramKerjaDetailView(data: p));
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
