import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dokumentasi_controller.dart';

class DokumentasiView extends GetView<DokumentasiController> {
  const DokumentasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumentasi Kegiatan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.photos.isEmpty) {
            return const Center(child: Text('Belum ada dokumentasi.'));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.photos.length,
            itemBuilder: (context, index) {
              final foto = controller.photos[index];
              return Card(
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  foto,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.tambahFotoDummy,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
