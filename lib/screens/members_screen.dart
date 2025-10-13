import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/org_provider.dart';
import '../models/member.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrgProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Anggota Organisasi')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (var m in prov.members)
            Card(
              child: ListTile(
                title: Text(m.name),
                subtitle: Text(m.role),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await prov.removeMember(m.id!);
                  },
                ),
                onTap: () async {
                  _nameCtrl.text = m.name;
                  _roleCtrl.text = m.role;
                  await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: const Text('Edit Anggota'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
                                TextField(controller: _roleCtrl, decoration: const InputDecoration(labelText: 'Role')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                              TextButton(
                                  onPressed: () async {
                                    final updated = Member(id: m.id, name: _nameCtrl.text, role: _roleCtrl.text);
                                    await prov.updateMember(updated);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Simpan')),
                            ],
                          ));
                },
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () async {
          _nameCtrl.clear();
          _roleCtrl.clear();
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text('Tambah Anggota'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
                        TextField(controller: _roleCtrl, decoration: const InputDecoration(labelText: 'Role')),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      TextButton(
                          onPressed: () async {
                            if (_nameCtrl.text.trim().isEmpty) return;
                            await prov.addMember(Member(name: _nameCtrl.text.trim(), role: _roleCtrl.text.trim()));
                            Navigator.pop(context);
                          },
                          child: const Text('Tambah')),
                    ],
                  ));
        },
      ),
    );
  }
}
