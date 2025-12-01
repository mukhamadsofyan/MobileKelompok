import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart'; // 🔥 ADD
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

  @override
  void initState() {
    super.initState();
    httpC = Get.put(ProgramControllerHttp());
    dioC = Get.put(ProgramControllerDio());
    modeC = Get.put(ModeController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modeC.mode.value == FetchMode.http) {
        httpC.fetchProgramByBidang(widget.bidangId);
      } else {
        dioC.fetchProgramByBidang(widget.bidangId);
      }
    });

    ever<FetchMode>(modeC.mode, (m) {
      if (m == FetchMode.http) {
        httpC.fetchProgramByBidang(widget.bidangId);
      } else {
        dioC.fetchProgramByBidang(widget.bidangId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>(); // 🔥 ADD

    final bg = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,

      // ===========================================================
      // APPBAR (ADD TOGGLE THEME)
      // ===========================================================
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0.4,

        title: Text(
          "Program: ${widget.bidangName}",
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),

        actions: [
          // 🔥 Toggle Dark/Light Mode
          Obx(() {
            return IconButton(
              icon: Icon(
                themeC.isDark ? Icons.dark_mode : Icons.light_mode,
                color: textColor,
                size: 26,
              ),
              onPressed: () => themeC.toggleTheme(),
            );
          }),

          // 🔥 Dropdown HTTP / DIO (existing)
          Obx(() {
            return DropdownButton<FetchMode>(
              value: modeC.mode.value,
              underline: const SizedBox(),
              dropdownColor: cardColor,
              style: TextStyle(color: textColor),
              icon: Icon(Icons.expand_more, color: textColor),
              items: const [
                DropdownMenuItem(value: FetchMode.http, child: Text("HTTP")),
                DropdownMenuItem(value: FetchMode.dio, child: Text("DIO")),
              ],
              onChanged: (v) {
                if (v != null) modeC.mode.value = v;
              },
            );
          }),
          const SizedBox(width: 8),
        ],
      ),

      // ===========================================================
      // BODY
      // ===========================================================
      body: Obx(() {
        final isHttp = modeC.mode.value == FetchMode.http;
        final list = isHttp ? httpC.programList : dioC.programList;
        final loading = isHttp ? httpC.loadingProgram : dioC.loadingProgram;
        final lastMs = isHttp ? httpC.lastFetchMs : dioC.lastFetchMs;
        final avgMs = isHttp ? httpC.averageFetchMs : dioC.averageFetchMs;
        final records = isHttp ? httpC.records : dioC.records;

        if (loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // =======================================================
            // INFO BAR (Mode & Fetch Time)
            // =======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(
                      Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05,
                    ),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mode: ${isHttp ? 'HTTP' : 'DIO'}",
                      style: TextStyle(color: textColor)),
                  Text("Last fetch: $lastMs ms",
                      style: TextStyle(color: textColor)),
                  Text("Average fetch: $avgMs ms",
                      style: TextStyle(color: textColor)),
                ],
              ),
            ),

            // =======================================================
            // LIST PROGRAM KERJA
            // =======================================================
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada program kerja",
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return Card(
                          color: cardColor,
                          elevation:
                              Theme.of(context).brightness == Brightness.dark ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              p.judul,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              p.deskripsi,
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // =======================================================
            // HISTORY FETCH
            // =======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.blueGrey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "History Fetch (Last & Avg ms)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Obx(() {
                    if (records.isEmpty) {
                      return Text(
                        "Belum ada record",
                        style: TextStyle(color: textColor),
                      );
                    }

                    return Column(
                      children: records.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // endpoint
                              Expanded(
                                flex: 2,
                                child: Text(
                                  r.endpoint,
                                  style: TextStyle(color: textColor),
                                ),
                              ),

                              // last ms
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "${r.lastMs} ms",
                                  style: TextStyle(color: textColor),
                                ),
                              ),

                              // average ms
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "${r.averageMs} ms",
                                  style: TextStyle(color: textColor),
                                ),
                              ),

                              // mode
                              Expanded(
                                flex: 1,
                                child: Text(
                                  r.mode,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
