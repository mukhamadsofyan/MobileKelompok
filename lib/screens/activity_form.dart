import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../provider/org_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ActivityForm extends StatefulWidget {
  final Activity? activity;
  const ActivityForm({super.key, this.activity});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime _date = DateTime.now();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _title = widget.activity!.title;
      _description = widget.activity!.description;
      _date = widget.activity!.date;
      _photoPath = widget.activity!.photoPath;
    } else {
      _title = '';
      _description = '';
    }
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final XFile? f = await p.pickImage(source: ImageSource.gallery);
    if (f != null) {
      setState(() {
        _photoPath = f.path;
      });
    }
  }

  Future<void> _takePhoto() async {
    final p = ImagePicker();
    final XFile? f = await p.pickImage(source: ImageSource.camera);
    if (f != null) {
      setState(() {
        _photoPath = f.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrgProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Tambah Kegiatan' : 'Edit Kegiatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Judul Kegiatan'),
                  validator: (v) => v == null || v.isEmpty ? 'Masukkan judul' : null,
                  onSaved: (v) => _title = v!.trim(),
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                  onSaved: (v) => _description = v!.trim(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Tanggal & Waktu'),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(_date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) {
                      TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
                      if (t != null) {
                        setState(() {
                          _date = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_photoPath != null)
                  Column(
                    children: [
                      Image.file(File(_photoPath!)),
                      TextButton.icon(
                          onPressed: () { setState(() { _photoPath = null; }); },
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus Foto'))
                    ],
                  ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pilih Foto'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ambil Foto'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState!.save();
                      final a = Activity(
                        id: widget.activity?.id,
                        title: _title,
                        description: _description,
                        date: _date,
                        photoPath: _photoPath,
                        completed: widget.activity?.completed ?? false,
                      );
                      if (widget.activity == null) {
                        await prov.addActivity(a);
                      } else {
                        await prov.updateActivity(a);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan')),
              ],
            )),
      ),
    );
  }
}
