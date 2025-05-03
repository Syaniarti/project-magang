import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  final String namaAwal;
  final String nipAwal;
  final String jabatanAwal;

  const EditProfilScreen({
    super.key,
    required this.namaAwal,
    required this.nipAwal,
    required this.jabatanAwal,
  });

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late TextEditingController _namaController;
  late TextEditingController _nipController;
  late TextEditingController _jabatanController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
    _nipController = TextEditingController(text: widget.nipAwal);
    _jabatanController = TextEditingController(text: widget.jabatanAwal);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  void _simpanProfil() {
    Navigator.pop(context, {
      'nama': _namaController.text,
      'nip': _nipController.text,
      'jabatan': _jabatanController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: _nipController,
              decoration: const InputDecoration(labelText: "NIP"),
            ),
            TextField(
              controller: _jabatanController,
              decoration: const InputDecoration(labelText: "Jabatan"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _simpanProfil,
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
