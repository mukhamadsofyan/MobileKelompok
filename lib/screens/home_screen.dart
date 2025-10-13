import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/org_provider.dart';
import 'activity_form.dart';
import 'activity_detail.dart';
import 'members_screen.dart';
import '../models/activity.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrgProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrgTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MembersScreen()),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ActivityForm())),
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: prov.loadAll,
              child: prov.activities.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Belum ada kegiatan. Tekan + untuk tambah.'))
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: prov.activities.length,
                      itemBuilder: (context, i) {
                        Activity a = prov.activities[i];
                        return Card(
                          child: ListTile(
                            title: Text(a.title),
                            subtitle: Text(
                                '${DateFormat.yMMMd().add_jm().format(a.date)} • ${a.description}'),
                            trailing: a.completed ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ActivityDetail(activity: a))),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
