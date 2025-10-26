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
      if (modeC.mode.value == FetchMode.http) httpC.fetchBidang();
      else dioC.fetchBidang();
    });

    ever<FetchMode>(modeC.mode, (m) {
      if (m == FetchMode.http) httpC.fetchBidang();
      else dioC.fetchBidang();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidang'),
        actions: [
          Obx(() => DropdownButton<FetchMode>(
                value: modeC.mode.value,
                underline: const SizedBox(),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: FetchMode.http, child: Text("HTTP")),
                  DropdownMenuItem(value: FetchMode.dio, child: Text("DIO")),
                ],
                onChanged: (val) => val != null ? modeC.mode.value = val : null,
              )),
        ],
      ),
      body: Obx(() {
        final isHttp = modeC.mode.value == FetchMode.http;
        final list = isHttp ? httpC.bidangList : dioC.bidangList;
        final loading = isHttp ? httpC.loadingBidang : dioC.loadingBidang;
        final lastMs = isHttp ? httpC.lastFetchMs : dioC.lastFetchMs;
        final avgMs = isHttp ? httpC.averageFetchMs : dioC.averageFetchMs;
        final records = isHttp ? httpC.records : dioC.records;

        if (loading.value) return const Center(child: CircularProgressIndicator());
        if (list.isEmpty) return const Center(child: Text("Belum ada bidang tersedia"));

        return Column(
          children: [
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(b.nama),
                      trailing: const Icon(Icons.arrow_forward_ios),
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
