import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';

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
  late final ProgramKerjaSupabaseController supaC;

  @override
  void initState() {
    super.initState();

    supaC = Get.find<ProgramKerjaSupabaseController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      supaC.fetchProgramKerja(widget.bidangId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorBG = Theme.of(context).colorScheme.background;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      backgroundColor: colorBG,
      body: Column(
        children: [
          _header(),

          Expanded(
            child: Obx(() {
              if (supaC.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = supaC.programList;

              if (list.isEmpty) {
                return const Center(
                  child: Text("Belum ada program kerja", style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];

                  return Card(
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
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

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
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
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
