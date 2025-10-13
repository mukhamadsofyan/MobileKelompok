import 'package:flutter/material.dart';

class ProgramKerjaScreen extends StatefulWidget {
  const ProgramKerjaScreen({super.key});

  @override
  State<ProgramKerjaScreen> createState() => _ProgramKerjaScreenState();
}

class _ProgramKerjaScreenState extends State<ProgramKerjaScreen> {
  final List<Map<String, String>> programs = [];

  void _addProgram() async {
    final nameCtrl = TextEditingController();
    String bidang = 'Kesejahteraan Mahasiswa';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Program Kerja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Program'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: bidang,
              decoration: const InputDecoration(labelText: 'Bidang'),
              items: const [
                DropdownMenuItem(
                    value: 'Kesejahteraan Mahasiswa',
                    child: Text('Kesejahteraan Mahasiswa')),
                DropdownMenuItem(
                    value: 'Pengabdian Masyarakat',
                    child: Text('Pengabdian Masyarakat')),
                DropdownMenuItem(
                    value: 'Komunikasi & Informasi',
                    child: Text('Komunikasi & Informasi')),
                DropdownMenuItem(
                    value: 'Seni & Olahraga', child: Text('Seni & Olahraga')),
              ],
              onChanged: (v) => bidang = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  Navigator.pop(context, {'nama': nameCtrl.text, 'bidang': bidang});
                }
              },
              child: const Text('Simpan'))
        ],
      ),
    );
    if (result != null) {
      setState(() => programs.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Kerja'),
        backgroundColor: Colors.orange,
      ),
      body: programs.isEmpty
          ? const Center(child: Text('Belum ada program kerja.'))
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context, i) {
                final p = programs[i];
                return Dismissible(
                  key: Key(p['nama']!),
                  onDismissed: (_) => setState(() => programs.removeAt(i)),
                  background: Container(color: Colors.redAccent),
                  child: ListTile(
                    title: Text(p['nama']!),
                    subtitle: Text('Bidang: ${p['bidang']}'),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProgram,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
