import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';
import 'package:orgtrack/app/ui/programkerja/views/programkerja_view.dart';
import '../controllers/bidang_controller.dart';

class BidangView extends StatelessWidget {
  const BidangView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BidangController());
    final programC = Get.put(ProgramController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Kerja'),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        if (c.bidangList.isEmpty) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.bidangList.length,
          itemBuilder: (_, i) {
            final b = c.bidangList[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(b['nama']),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => ProgramKerjaView(
                        bidangId: b['id'],
                        bidangName: b['nama'],
                      ));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
