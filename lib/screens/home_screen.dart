import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'members_screen.dart';
import '../models/activity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk contoh halaman absensi
    final dummyActivity = Activity(
      id: 1,
      title: 'Kegiatan Rutin',
      date: DateTime.now(),
      description: 'Absensi kegiatan rutin mingguan',
    );

    // Daftar menu di dashboard
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
        'page': null,
      },
      {
        'title': 'Keuangan',
        'icon': Icons.account_balance_wallet,
        'color': Colors.green,
        'page': null,
      },
      {
        'title': 'Laporan',
        'icon': Icons.bar_chart,
        'color': Colors.indigo,
        'page': null,
      },
      {
        'title': 'Pengaturan',
        'icon': Icons.settings,
        'color': Colors.grey,
        'page': null,
      },
    ];

    // Menggunakan MediaQuery untuk menentukan jumlah kolom
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
      // LayoutBuilder menyesuaikan grid terhadap ruang lokal
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

// ==============================
// Widget Kartu Menu dengan Animasi Hover
// ==============================
class _AnimatedMenuItem extends StatefulWidget {
  final Map<String, dynamic> item;
  const _AnimatedMenuItem({required this.item});

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item['color'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.07 : 1.0)
          ..translate(0, _isHovered ? -4 : 0), // efek naik sedikit
        decoration: BoxDecoration(
          color: _isHovered ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  _isHovered ? color.withOpacity(0.4) : Colors.black12,
              blurRadius: _isHovered ? 14 : 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.2),
          highlightColor: Colors.transparent,
          onTap: () {
            if (widget.item['page'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget.item['page']),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Menu "${widget.item['title']}" belum aktif'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: _isHovered ? 1.15 : 1.0,
                curve: Curves.easeOutBack,
                child: Icon(
                  widget.item['icon'] as IconData,
                  color: color,
                  size: _isHovered ? 52 : 42,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: _isHovered ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? color : Colors.black87,
                  letterSpacing: _isHovered ? 0.5 : 0.2,
                ),
                child: Text(widget.item['title'] as String),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
