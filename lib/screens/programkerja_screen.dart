import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgramKerjaScreen extends StatefulWidget {
  const ProgramKerjaScreen({super.key});

  @override
  State<ProgramKerjaScreen> createState() => _ProgramKerjaScreenState();
}

class _ProgramKerjaScreenState extends State<ProgramKerjaScreen> {
  final List<String> bidangList = [
    'Kesejahteraan Mahasiswa',
    'Pengabdian Masyarakat',
    'Komunikasi & Informasi',
    'Seni & Olahraga',
  ];

  String? selectedBidang;
  List<Map<String, String>> programList = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('programKerja') ?? '{}';
    final Map<String, dynamic> storedData = json.decode(data);
    if (selectedBidang != null && storedData[selectedBidang] != null) {
      setState(() {
        programList = List<Map<String, String>>.from(storedData[selectedBidang]);
      });
    }
  }

  Future<void> _savePrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('programKerja') ?? '{}';
    final Map<String, dynamic> storedData = json.decode(data);
    storedData[selectedBidang!] = programList;
    prefs.setString('programKerja', json.encode(storedData));
  }

  void _addProgram() async {
    final nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Program Kerja'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Program'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) Navigator.pop(context, nameCtrl.text);
              },
              child: const Text('Simpan'))
        ],
      ),
    );
    if (result != null) {
      setState(() {
        programList.add({'nama': result});
      });
      _savePrograms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Kerja'),
        backgroundColor: Colors.orange,
      ),
      body: selectedBidang == null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: bidangList
                  .map((b) => Card(
                        child: ListTile(
                          title: Text(b),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            setState(() => selectedBidang = b);
                            await _loadPrograms();
                          },
                        ),
                      ))
                  .toList(),
            )
          : Column(
              children: [
                Container(
                  color: Colors.orange.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => selectedBidang = null),
                      ),
                      Text(
                        'Bidang: $selectedBidang',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: programList.isEmpty
                      ? const Center(child: Text('Belum ada program kerja.'))
                      : ListView.builder(
                          itemCount: programList.length,
                          itemBuilder: (context, i) {
                            final p = programList[i];
                            return Dismissible(
                              key: Key(p['nama']!),
                              onDismissed: (_) {
                                setState(() => programList.removeAt(i));
                                _savePrograms();
                              },
                              background: Container(color: Colors.redAccent),
                              child: ListTile(title: Text(p['nama']!)),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: selectedBidang == null
          ? null
          : FloatingActionButton(
              onPressed: _addProgram,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
            ),
    );
  }
}
