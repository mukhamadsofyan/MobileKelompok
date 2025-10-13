import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  final List<Map<String, dynamic>> records = [];

  void _addRecord() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'Pemasukan';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Keterangan')),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
              ],
              onChanged: (v) => type = v!,
              decoration: const InputDecoration(labelText: 'Jenis'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                Navigator.pop(context, {
                  'keterangan': nameCtrl.text,
                  'nominal': double.tryParse(amountCtrl.text) ?? 0,
                  'jenis': type,
                  'tanggal': DateTime.now(),
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => records.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: const Text('Keuangan'), backgroundColor: Colors.green),
      body: records.isEmpty
          ? const Center(child: Text('Belum ada data keuangan.'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, i) {
                final r = records[i];
                return Dismissible(
                  key: Key(r['keterangan']),
                  onDismissed: (_) => setState(() => records.removeAt(i)),
                  background: Container(color: Colors.redAccent),
                  child: ListTile(
                    leading: Icon(r['jenis'] == 'Pemasukan' ? Icons.arrow_downward : Icons.arrow_upward,
                        color: r['jenis'] == 'Pemasukan' ? Colors.green : Colors.red),
                    title: Text(r['keterangan']),
                    subtitle: Text(DateFormat.yMMMd().format(r['tanggal'])),
                    trailing: Text(format.format(r['nominal']),
                        style: TextStyle(
                            color: r['jenis'] == 'Pemasukan' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
