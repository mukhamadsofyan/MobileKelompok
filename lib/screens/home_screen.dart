import 'package:flutter/material.dart';
import 'members_screen.dart'; // halaman anggota
import 'attendance_screen.dart'; // halaman absensi
import '../models/activity.dart'; // untuk dummy Activity object

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy activity agar tidak error (karena AttendanceScreen butuh data Activity)
    final dummyActivity = Activity(
      id: 1,
      title: 'Kegiatan Rutin',
      date: DateTime.now(),
      description: 'Absensi kegiatan rutin mingguan',
    );

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Absensi',
        'icon': Icons.check_circle,
        'color': Colors.teal,
        'page': AttendanceScreen(activity: dummyActivity),
      },
      {
        'title': 'Anggota',
        'icon': Icons.group,
        'color': Colors.blueAccent,
        'page': const MembersScreen(),
      },
      {
        'title': 'Kegiatan',
        'icon': Icons.event,
        'color': Colors.orange,
        'page': null, // nanti diarahkan ke ActivityScreen
      },
      {
        'title': 'Laporan',
        'icon': Icons.bar_chart,
        'color': Colors.green,
        'page': null,
      },
      {
        'title': 'Forum',
        'icon': Icons.chat,
        'color': Colors.purple,
        'page': null,
      },
      {
        'title': 'Pengaturan',
        'icon': Icons.settings,
        'color': Colors.grey,
        'page': null,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
        title: const Text(
          'OrgTrack Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (item['page'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page']),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menu "${item['title']}" belum aktif'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
