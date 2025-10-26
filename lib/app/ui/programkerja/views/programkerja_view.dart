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
    httpC = Get.put(ProgramControllerHttp());
    dioC = Get.put(ProgramControllerDio());
    modeC = Get.put(ModeController());

    // Fetch awal sesuai mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modeC.mode.value == FetchMode.http) {
        httpC.fetchProgramByBidang(widget.bidangId);
      } else {
        dioC.fetchProgramByBidang(widget.bidangId);
      }
    });

    // Fetch ulang saat mode berubah
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
      appBar: AppBar(
        title: Text("Program: ${widget.bidangName}"),
        actions: [
          Obx(() => DropdownButton<FetchMode>(
                value: modeC.mode.value,
                underline: const SizedBox(),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: FetchMode.http, child: Text("HTTP")),
                  DropdownMenuItem(value: FetchMode.dio, child: Text("DIO")),
                ],
                onChanged: (val) {
                  if (val != null) modeC.mode.value = val;
                },
              )),
        ],
      ),
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
            // Info singkat mode & fetch time
            Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode: ${isHttp ? 'HTTP' : 'DIO'}'),
                  Text('Last fetch: $lastMs ms'),
                  Text('Average fetch: $avgMs ms'),
                ],
              ),
            ),

            // List program kerja
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text("Belum ada program kerja"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(p.judul),
                            subtitle: Text(p.deskripsi),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        );
                      },
                    ),
            ),

            // Tabel history fetch
            Container(
              width: double.infinity,
              color: Colors.blueGrey.shade50,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History Fetch (Last & Average ms)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Obx(() {
                    if (records.isEmpty) return const Text("Belum ada record");
                    return Column(
                      children: records.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
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
    );
  }
}
