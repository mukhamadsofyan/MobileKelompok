import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import 'activity_form.dart';
import '../provider/org_provider.dart';
import 'attendance_screen.dart';
import 'package:intl/intl.dart';

class ActivityDetail extends StatelessWidget {
  final Activity activity;
  const ActivityDetail({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrgProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ActivityForm(activity: activity)));
              }),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text('Hapus kegiatan?'),
                          content: const Text('Data akan dihapus permanen.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ));
                if (ok == true) {
                  await prov.removeActivity(activity.id!);
                  if (context.mounted) Navigator.pop(context);
                }
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(activity.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(DateFormat.yMMMd().add_jm().format(activity.date)),
            const SizedBox(height: 12),
            Text(activity.description),
            const SizedBox(height: 12),
            if (activity.photoPath != null)
              Image.file(File(activity.photoPath!)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.checklist),
              label: const Text('Absensi & Kehadiran'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(activity: activity)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
