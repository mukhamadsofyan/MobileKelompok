import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'members_screen.dart';
import 'programkerja_screen.dart';
import 'keuangan_screen.dart';
import 'placeholder_screen.dart';
import '../models/activity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        'title': 'Program Kerja',
        'icon': Icons.work,
        'color': Colors.orange,
        'page': const ProgramKerjaScreen(),
      },
      {
        'title': 'Keuangan',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'page': const KeuanganScreen(),
      },
      {
        'title': 'Kegiatan',
        'icon': Icons.event,
        'color': Colors.purple,
        'page': const PlaceholderScreen(title: 'Kegiatan'),
      },
      {
        'title': 'Pengaturan',
        'icon': Icons.settings,
        'color': Colors.grey,
        'page': const PlaceholderScreen(title: 'Pengaturan'),
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: menuItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    constraints.maxWidth < 600 ? 1 : 1.1,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _AnimatedMenuItem(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final Map<String, dynamic> item;
  const _AnimatedMenuItem({required this.item});

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item['color'] as Color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 150));
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget.item['page']),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform:
            Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? color.withOpacity(0.3)
                  : Colors.black12.withOpacity(0.1),
              blurRadius: _isPressed ? 12 : 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isPressed ? 60 : 70,
              width: _isPressed ? 60 : 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.item['icon'] as IconData,
                color: color,
                size: _isPressed ? 36 : 40,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item['title'] as String,
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
  }
}
