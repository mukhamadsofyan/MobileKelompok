import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'members_screen.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 900
            ? 3
            : 4;

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
                childAspectRatio: constraints.maxWidth < 600 ? 1 : 1.1,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _ControlledMenuItem(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ControlledMenuItem extends StatefulWidget {
  final Map<String, dynamic> item;
  const _ControlledMenuItem({required this.item});

  @override
  State<_ControlledMenuItem> createState() => _ControlledMenuItemState();
}

class _ControlledMenuItemState extends State<_ControlledMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    final color = widget.item['color'] as Color;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.07)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shadowAnimation = Tween<double>(begin: 6.0, end: 14.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _colorAnimation = ColorTween(begin: Colors.white, end: color.withOpacity(0.15))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    if (hover) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item['color'] as Color;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: _shadowAnimation.value,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (widget.item['page'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => widget.item['page']),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menu "${widget.item['title']}" belum aktif'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.item['icon'] as IconData,
                      color: color,
                      size: 45 + (_controller.value * 7),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item['title'] as String,
                      style: TextStyle(
                        fontSize: 16 + (_controller.value * 2),
                        fontWeight: FontWeight.w600,
                        color: _controller.value > 0.5 ? color : Colors.black87,
                        letterSpacing: 0.3 + (_controller.value * 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
