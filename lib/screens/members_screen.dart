import 'package:flutter/material.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final List<Map<String, String>> members = [];

  void _addMember() async {
    final controllerName = TextEditingController();
    final controllerRole = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Anggota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: 'Nama Anggota',
              ),
            ),
            TextField(
              controller: controllerRole,
              decoration: const InputDecoration(
                labelText: 'Jabatan / Peran',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controllerName.text.isNotEmpty &&
                  controllerRole.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': controllerName.text,
                  'role': controllerRole.text,
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => members.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anggota'),
        backgroundColor: Colors.blueAccent,
      ),
      body: members.isEmpty
          ? const Center(
              child: Text(
                'Belum ada anggota.\nTekan tombol + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(m['name'] ?? ''),
                    subtitle: Text(m['role'] ?? ''),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
