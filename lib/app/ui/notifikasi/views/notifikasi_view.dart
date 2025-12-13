import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:orgtrack/app/ui/notifikasi/controllers/notifikasi_controller.dart';
import 'dart:ui';

import '../../../routes/app_pages.dart';

class NotifikasiView extends StatefulWidget {
  const NotifikasiView({super.key});

  @override
  State<NotifikasiView> createState() => _NotifikasiViewState();
}

class _NotifikasiViewState extends State<NotifikasiView> {
  int _currentIndex = 1;

  final NotificationController notificationController =
      Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF8),
      appBar: AppBar(
        title: const Text(
          'Notifikasi Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Obx(() {
        final notifs = notificationController.notifications;

        if (notifs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 100, color: Colors.teal.shade200),
                const SizedBox(height: 12),
                Text(
                  "Belum ada notifikasi",
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: notifs.length,
          itemBuilder: (_, i) {
            final notif = notifs[i];
            final formattedDate =
                DateFormat('dd MMM yyyy, HH:mm').format(notif.time);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications,
                      color: Colors.teal.shade700, size: 28),
                ),
                title: Text(
                  notif.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 15, color: Colors.teal.shade600),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {
                  final type = notif.payload['type'];

                  if (type == 'agenda') {
                    Get.toNamed(
                      Routes.AGENDA_ORGANISASI,
                      arguments: notif.payload,
                    );
                  } else {
                    _showDetail(
                        notif.title, notif.body, formattedDate);
                  }
                },
              ),
            );
          },
        );
      }),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ===== DETAIL DIALOG (TETAP SAMA) =====
  void _showDetail(String title, String desc, String date) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(date,
                        style: TextStyle(
                            color: Colors.teal.shade600)),
                    const SizedBox(height: 14),
                    Text(desc,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tutup"),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== BOTTOM NAV (TIDAK DIUBAH) =====
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal.shade700,
      unselectedItemColor: Colors.grey.shade500,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            Get.offAllNamed(Routes.HOME);
            break;
          case 1:
            Get.toNamed(Routes.NOTIFIKASI);
            break;
          case 2:
            Get.toNamed(Routes.AGENDA_ORGANISASI);
            break;
          case 3:
            Get.toNamed(Routes.STRUKTUR);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notifikasi'),
        BottomNavigationBarItem(
            icon: Icon(Icons.event_note), label: 'Agenda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
