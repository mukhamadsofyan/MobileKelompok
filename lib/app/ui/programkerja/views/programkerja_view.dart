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

  // ================= POPUP DETAIL =================
  void _showDetailPopup(BuildContext context, dynamic p) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (p.judul ?? "-").toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textColor),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "Deskripsi Program",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (p.deskripsi ?? "Tidak ada deskripsi").toString(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: textColor.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline, color: Colors.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Bidang: ${widget.bidangName}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
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
            // ================= HEADER RAPI =================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Program Kerja",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.bidangName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => themeC.toggleTheme(),
                        icon: Icon(
                          themeC.isDark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark
                                ? 0.25
                                : 0.12,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => q.value = v,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Cari program kerja...",
                        hintStyle:
                            TextStyle(color: textColor.withOpacity(0.6)),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.teal),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= LIST =================
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        q.value.isEmpty
                            ? "Belum ada program kerja"
                            : "Tidak ada hasil pencarian",
                        style:
                            TextStyle(color: textColor.withOpacity(0.8)),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            title: Text(
                              (p.judul ?? "-").toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                                ),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: textColor.withOpacity(0.6),
                            ),
                            onTap: () =>
                                _showDetailPopup(context, p),
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
