import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    // =========================
    // FIX: pakai Get.find, bukan Get.put
    // =========================
    httpC = Get.find<ProgramControllerHttp>();
    dioC = Get.find<ProgramControllerDio>();
    modeC = Get.find<ModeController>();

    // Fetch awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modeC.mode.value == FetchMode.http) {
        httpC.fetchProgramByBidang(widget.bidangId);
      } else {
        dioC.fetchProgramByBidang(widget.bidangId);
      }
    });

    // Fetch ulang ketika mode berubah
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),

      // =========================
      // HEADER PREMIUM + HERO RECEIVER
      // =========================
      body: Column(
        children: [
          _header(),

          Expanded(
            child: Obx(() {
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
                  // =========================
                  // INFO MODE FETCH
                  // =========================
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode: ${isHttp ? 'HTTP' : 'DIO'}'),
                        Text('Last fetch: $lastMs ms'),
                        Text('Average: $avgMs ms'),
                      ],
                    ),
                  ),

                  // =========================
                  // LIST PROGRAM KERJA
                  // =========================
                  Expanded(
                    child: list.isEmpty
                        ? const Center(child: Text("Belum ada program kerja"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final p = list[i];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    p.judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(p.deskripsi),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // =========================
                  // HISTORY FETCH
                  // =========================
                  Container(
                    width: double.infinity,
                    color: Colors.blueGrey.shade50,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Riwayat Fetch",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() {
                          if (records.isEmpty) {
                            return const Text("Belum ada record");
                          }

                          return Column(
                            children: records.map((r) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(flex: 2, child: Text(r.endpoint)),
                                    Expanded(flex: 1, child: Text('${r.lastMs} ms')),
                                    Expanded(flex: 1, child: Text('${r.averageMs} ms')),
                                    Expanded(flex: 1, child: Text(r.mode)),
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
          ),
        ],
      ),
    );
  }

  // =============================
  // HEADER + HERO
  // =============================
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // =============================
          // HERO RECEIVER (WAJIB!)
          // =============================
          Hero(
            tag: "title_${widget.bidangId}",
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.bidangName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
