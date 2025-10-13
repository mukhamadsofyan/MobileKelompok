import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'package:provider/provider.dart';
import '../provider/org_provider.dart';

class AttendanceScreen extends StatefulWidget {
  final Activity activity;
  const AttendanceScreen({super.key, required this.activity});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrgProvider>(context);
    final members = prov.members;
    return Scaffold(
      appBar: AppBar(title: Text('Absensi: ${widget.activity.title}')),
      body: members.isEmpty
          ? const Center(child: Text('Belum ada anggota. Tambah anggota dulu.'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                // return FutureBuilder(
                //   future: prov._db.getAttendanceForActivity(widget.activity.id!), // not ideal to call internal, but for simplicity
                //   builder: (context, snap) {
                //     // We'll show simple toggle and call markAttendance on tap
                //     return ListTile(
                //       title: Text(m.name),
                //       subtitle: Text(m.role),
                //       trailing: ElevatedButton(
                //         child: const Text('Hadir'),
                //         onPressed: () async {
                //           await prov.markAttendance(widget.activity.id!, m.id!, true);
                //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tercatat hadir')));
                //         },
                //       ),
                //     );
                //   },
                // );
              },
            ),
    );
  }
}
